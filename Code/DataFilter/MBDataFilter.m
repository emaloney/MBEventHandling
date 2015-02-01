//
//  MBDataFilter.m
//  Mockingbird Event Handling
//
//  Created by Jesse Boyes on 8/15/09.
//  Copyright (c) 2009 Gilt Groupe. All rights reserved.
//

#import <RaptureXML@Gilt/RXMLElement.h>
#import <MBDataEnvironment/MBDataEnvironment.h>

#import "MBDataFilter.h"
#import "MBEventHandlingModule.h"

#define DEBUG_LOCAL		0

/******************************************************************************/
#pragma mark Private constants
/******************************************************************************/

#define kDataFilterTag                      @"DataFilter"
#define kDataFilterAttributeFilterVar       @"filterVar"
#define kDataFilterAttributeFilterValue     @"filterValue"
#define kDataFilterAttributeFilterExpr      @"filterExpr"

/******************************************************************************/
#pragma mark -
#pragma mark MBDataFilter implementation
/******************************************************************************/

@implementation MBDataFilter
{
    BOOL _substring;
}

/******************************************************************************/
#pragma mark Data model support
/******************************************************************************/

+ (NSString*) dataEntityName
{
    return kDataFilterTag;
}

+ (NSSet*) supportedAttributes
{
    return [NSSet setWithObjects:kMBMLAttributeName,
            kMBMLAttributeVar,
            kMBMLAttributeIf,
            kMBMLAttributeDataSource,
            kDataFilterAttributeFilterExpr,
            kDataFilterAttributeFilterVar,
            kDataFilterAttributeFilterValue,
            nil];
}

- (void) populateDataModelFromXML:(RXMLElement*)container
{
    debugTrace();
    
    [self addRelativeOfClass:[MBDataFilter class]
              forEachChildOf:container
                   havingTag:kDataFilterTag];
}

- (BOOL) validateAsRelativeOf:(MBDataModel*)relative
                    relatedBy:(NSString*)relationType
                dataModelRoot:(MBDataModel*)root
{
    debugTrace();
    
    if (![super validateAsRelativeOf:relative relatedBy:relationType dataModelRoot:root]) {
        return NO;
    }

    if ([self valueOfAttribute:@"filterClass"]) {
        [[MBEventHandlingModule log] issueNotSupportedErrorWithFormat:@"DataFilters no longer support custom filter classes. Filters specifying the filterClass attribute will not be executed. This filter will be ignored: %@", self.simulatedXML];
        return NO;
    }
    
    NSString* name = [self stringValueOfAttribute:kMBMLAttributeName];
    NSString* varName = [self stringValueOfAttribute:kMBMLAttributeVar];
    
    NSArray* contained = [self containedFilters];
    if (self == root) {
        // we're a top-level filter
        if (contained.count) {
            // we're the top-level data filter for a set of other filters
            NSUInteger attrCnt = [self countAttributes];
            if (attrCnt > 1 && name.length) {
                if (attrCnt > 2 || (attrCnt == 2 && ![self hasAttribute:kMBMLAttributeIf])) {
                    errorLog(@"%@s that contain other %@s may only specify the attributes \"%@\" and \"%@\"; additional attributes will be ignored: %@", kDataFilterTag, kDataFilterTag, kMBMLAttributeName, kMBMLAttributeIf, self.simulatedXML);
                }
            }
            else if (!name.length) {
                errorLog(@"%@s that contain other %@s must specify a value for the \"%@\" attribute: %@", kDataFilterTag, kDataFilterTag, kMBMLAttributeName, self.simulatedXML);
                return NO;
            }
        }
        else {
            // we're not contained in another filter, and we contain no filters;
            // we're a top-level, stand-alone filter!
            if (!name.length && !varName.length) {
                errorLog(@"%@s require a value for either the \"%@\" or the \"%@\" attribute in order to know where to store the result: %@", kDataFilterTag, kMBMLAttributeName, kMBMLAttributeVar, self.simulatedXML);
                return NO;
            }
        }
    }
    else {
        // we're contained in another filter
        if (contained.count) {
            // contained filters can't in turn contain other filters
            errorLog(@"%@s can only be nested one-level deep; a %@ contained in another %@ cannot in turn contain a %@: %@", kDataFilterTag, kDataFilterTag, kDataFilterTag, kDataFilterTag, self.simulatedXML);
            return NO;
        }
        else {
            if (name.length) {
                errorLog(@"%@s that are contained in another %@ may not specify a \"%@\" attribute: %@", kDataFilterTag, kDataFilterTag, kMBMLAttributeName, self.simulatedXML);
                return NO;
            }
            else if (!varName.length) {
                errorLog(@"%@s that are contained in another %@ must specify a value for the \"%@\" attribute: %@", kDataFilterTag, kDataFilterTag, kMBMLAttributeVar, self.simulatedXML);
                return NO;
            }
        }
    }
    return YES;
}

/******************************************************************************/
#pragma mark Property handling
/******************************************************************************/

- (NSString*) name
{
    return [self stringValueOfAttribute:kMBMLAttributeName];
}

- (NSString*) var
{
    NSString* varName = [self stringValueOfAttribute:kMBMLAttributeVar];
    if (!varName) {
        varName = [self stringValueOfAttribute:kMBMLAttributeName];
    }
    return varName;
}

/******************************************************************************/
#pragma mark Filtering implementation
/******************************************************************************/

- (NSArray*) containedFilters
{
    return [self relativesWithRelationType:kDataFilterTag];
}

- (NSArray*) filterByFieldCriteria:(NSArray*)data 
{
    debugTrace();
    
    NSString* expandedFilterValue = [self evaluateAsString:kDataFilterAttributeFilterValue];
    NSString* expandedFilterVar = [self evaluateAsString:kDataFilterAttributeFilterVar];
    
    if (!expandedFilterValue || !expandedFilterVar) {
        // Empty filter parameters? Filter result = entire list.
        return data;
    }
    
    NSMutableArray* filtered = [NSMutableArray array];    
    for (id item in data) {
        if ([item isKindOfClass:[NSArray class]]) {
            NSArray* subFilteredArray = [self filterByFieldCriteria:item];
            if (subFilteredArray.count > 0) // Prune empty sub-arrays
                [filtered addObject:subFilteredArray];
        } else {
            
            id value = nil;
            // Either look var up in the dictionary, or use KVC to retrieve the field value.
            if ([item respondsToSelector:@selector(objectForKey:)])
                value = [item objectForKey:expandedFilterVar];
            else
                value = [item valueForKey:expandedFilterVar];
            
            if ([value isKindOfClass:[NSArray class]]) { // Walk through arrays to check for containment
                for (NSString* subVar in value) {
                    if (_substring) {
                        if ([subVar rangeOfString:expandedFilterValue options:NSCaseInsensitiveSearch].location != NSNotFound) {
                            [filtered addObject:item];
                            break;
                        }
                    }
                    else {
                        if ([expandedFilterValue isEqualToString:subVar]) {
                            [filtered addObject:item];
                            break;
                        }
                    }
                }
            } else {
                if (![value isKindOfClass:[NSString class]] && [value respondsToSelector:@selector(stringValue)])
                    value = [value stringValue];

                if (_substring) {
                    if ([value rangeOfString:expandedFilterValue options:NSCaseInsensitiveSearch].location != NSNotFound)
                        [filtered addObject:item];
                }
                else if ([expandedFilterValue isEqualToString:value]) { // Otherwise assume it's a string.
                    [filtered addObject:item];
                }
            }
        }
    }
    debugLog(@"Filtered array size: %ld", (unsigned long)filtered.count);
    return filtered;
}

- (NSArray*) filterData:(NSObject<NSFastEnumeration>*)data usingExpression:(NSString*)filterExpr
{
    debugTrace();
    
    NSMutableArray* filtered = [NSMutableArray array];
    MBVariableSpace* vars = [MBVariableSpace instance];
    for (__strong id item in data) {
        BOOL isDict = [data isKindOfClass:[NSDictionary class]];
        if (isDict) {
            [vars pushVariable:kMBMLVariableKey value:item];
            item = ((NSDictionary*)data)[item];
        }
        if ([item isKindOfClass:[NSArray class]]) {
            NSArray* subFilteredArray = [self filterData:item usingExpression:filterExpr];
            if (subFilteredArray.count > 0) // Prune empty sub-arrays
                [filtered addObject:subFilteredArray];
        }
        else {
            [vars pushVariable:kMBMLVariableItem value:item];
            if ([filterExpr evaluateAsBoolean]) {
                [filtered addObject:item];
            }
            [vars popVariable:kMBMLVariableItem];
        }
        if (isDict) {
            [vars popVariable:kMBMLVariableKey];
        }
    }
    return filtered;
}

/******************************************************************************/
#pragma mark Executing the filter
/******************************************************************************/

- (void) refreshData 
{
    debugTrace();
    
    NSString* varName = self.var;
    NSString* dataSource = [self stringValueOfAttribute:kMBMLAttributeDataSource];
    
    if (![self evaluateAsBoolean:kMBMLAttributeIf defaultValue:YES]) {
        debugLog(@"Skipping refresh of DataFilter because if clause is false: %@", self);
        return;
    }
    
    NSArray* contained = [self containedFilters];
    if (contained.count) {
        for (MBDataFilter* filter in contained) {
            [filter refreshData];
        }
    }
    else if (dataSource) {
        id value = [dataSource evaluateAsObject];
        
        BOOL isEnumerable = [value conformsToProtocol:@protocol(NSFastEnumeration)];
        NSString* filterExpr = [self stringValueOfAttribute:kDataFilterAttributeFilterExpr];
        if (isEnumerable && filterExpr) {
            value = [self filterData:value usingExpression:filterExpr];
        }

        BOOL isArray = [value isKindOfClass:[NSArray class]];
        if (isArray) {
            if ([self hasAttribute:kDataFilterAttributeFilterVar]) {
                value = [self filterByFieldCriteria:value];
            } 
        }
        
        [MBVariableSpace instance][varName] = value;
    }
    else {
        [[MBVariableSpace instance] unsetVariable:varName];
    }

    NSString* name = [self stringValueOfAttribute:kMBMLAttributeName];
    NSString* event = (name ?: varName);
    if (event.length > 0) {
        debugLog(@"Refreshed DataFilter: %@", event);
        [MBEvents postDataLoaded:event];
    }
}

@end
