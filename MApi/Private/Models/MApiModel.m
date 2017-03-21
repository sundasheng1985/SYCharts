//
//  MApiModel.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/5/27.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MApiModel.h"
#import <objc/runtime.h>

@implementation MApiModel

#pragma mark - override 

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> %@", self.class, self, [self dictionaryRepresentation:YES]];
}

- (NSUInteger)hash {
    NSUInteger value = 0;
    for (NSString *key in [self codableProperties]) {
        value ^= [[self valueForKey:key] hash];
    }
    return value;
}

- (BOOL)isEqual:(id)other {
    if (other == self) return YES;
    if (![other isMemberOfClass:self.class]) return NO;
    
    for (NSString *key in [self codableProperties]) {
        id selfValue = [self valueForKey:key];
        id otherValue = [other valueForKey:key];
        
        BOOL valuesEqual = ((selfValue == nil && otherValue == nil) || [selfValue isEqual:otherValue]);
        if (!valuesEqual) return NO;
    };
    return YES;
}


#pragma mark - private 

+ (instancetype)objectWithContentsOfFile:(NSString *)filePath {
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    id object = nil;
    if (data) {
        NSPropertyListFormat format;
        object = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:&format error:NULL];
        if (object) {
            //check if object is an NSCoded unarchive
            if ([object respondsToSelector:@selector(objectForKey:)] && [(NSDictionary *)object objectForKey:@"$archiver"]) {
                object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
        } else {
            // return raw data
            object = data;
        }
    }
    return object;
}

- (BOOL)writeToFile:(NSString *)filePath atomically:(BOOL)useAuxiliaryFile {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    return [data writeToFile:filePath atomically:useAuxiliaryFile];
}

+ (NSDictionary *)codablePropertiesForDesciption:(BOOL)forDesciption {
    
    unsigned int propertyCount;
    __autoreleasing NSMutableDictionary *codableProperties = [NSMutableDictionary dictionary];
    objc_property_t *properties = class_copyPropertyList(self, &propertyCount);
    for (unsigned int i = 0; i < propertyCount; i++) {
        //get property name
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        __autoreleasing NSString *key = @(propertyName);
        
        //get property type
        Class propertyClass = nil;
        char *typeEncoding = property_copyAttributeValue(property, "T");
        switch (typeEncoding[0])
        {
            case '@':
            {
                if (strlen(typeEncoding) >= 3)
                {
                    char *className = strndup(typeEncoding + 2, strlen(typeEncoding) - 3);
                    __autoreleasing NSString *name = @(className);
                    NSRange range = [name rangeOfString:@"<"];
                    if (range.location != NSNotFound)
                    {
                        name = [name substringToIndex:range.location];
                    }
                    propertyClass = NSClassFromString(name) ?: [NSObject class];
                    free(className);
                }
                break;
            }
            case 'c':
            case 'i':
            case 's':
            case 'l':
            case 'q':
            case 'C':
            case 'I':
            case 'S':
            case 'L':
            case 'Q':
            case 'f':
            case 'd':
            case 'B':
            {
                propertyClass = [NSNumber class];
                break;
            }
            case '{':
            {
                propertyClass = [NSValue class];
                break;
            }
        }
        free(typeEncoding);
        
        if (propertyClass) {
            char *ivar = property_copyAttributeValue(property, "V");
            if (ivar) {
                __autoreleasing NSString *ivarName = @(ivar);
                if ([ivarName isEqualToString:key] ||
                    [ivarName isEqualToString:[@"_" stringByAppendingString:key]]) {
                    codableProperties[key] = propertyClass;
                }
                /// 不是給desc，而是需要encode的original data
                else if (!forDesciption &&
                         [ivarName isEqualToString:[@"original_" stringByAppendingString:key]]) {
                    codableProperties[key] = propertyClass;
                }
                free(ivar);
            }
            else {
                char *dynamic = property_copyAttributeValue(property, "D");
                char *readonly = property_copyAttributeValue(property, "R");
                if (dynamic && !readonly) { // no ivar, but setValue:forKey: will still work
                    codableProperties[key] = propertyClass;
                }
                free(dynamic);
                free(readonly);
            }
        }
    }
    
    free(properties);
    return codableProperties;
}

- (NSDictionary *)codableProperties {
    __autoreleasing NSDictionary *codableProperties = objc_getAssociatedObject([self class], _cmd);
    if (!codableProperties) {
        codableProperties = [NSMutableDictionary dictionary];
        Class subclass = [self class];
        while (subclass != [NSObject class]) {
            [(NSMutableDictionary *)codableProperties addEntriesFromDictionary:[subclass codablePropertiesForDesciption:NO]];
            subclass = [subclass superclass];
        }
        codableProperties = [NSDictionary dictionaryWithDictionary:codableProperties];
        objc_setAssociatedObject([self class], _cmd, codableProperties, OBJC_ASSOCIATION_RETAIN);
    }
    return codableProperties;
}

- (NSDictionary *)descriptionProperties {
    __autoreleasing NSDictionary *descriptionProperties = objc_getAssociatedObject([self class], _cmd);
    if (!descriptionProperties) {
        descriptionProperties = [NSMutableDictionary dictionary];
        Class subclass = [self class];
        while (subclass != [NSObject class]) {
            [(NSMutableDictionary *)descriptionProperties addEntriesFromDictionary:[subclass codablePropertiesForDesciption:YES]];
            subclass = [subclass superclass];
        }
        descriptionProperties = [NSDictionary dictionaryWithDictionary:descriptionProperties];
        objc_setAssociatedObject([self class], _cmd, descriptionProperties, OBJC_ASSOCIATION_RETAIN);
    }
    return descriptionProperties;
}

- (NSDictionary *)dictionaryRepresentation:(BOOL)forDesciption {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (__unsafe_unretained NSString *key in forDesciption?[self descriptionProperties]:[self codableProperties])
    {
        id value = [self valueForKey:key];
        if (value) dict[key] = value;
        else dict[key] = [NSNull null];
    }
    return dict;
}

- (void)setWithCoder:(NSCoder *)aDecoder {
    BOOL secureAvailable = [aDecoder respondsToSelector:@selector(decodeObjectOfClass:forKey:)];
    BOOL secureSupported = [[self class] supportsSecureCoding];
    NSDictionary *properties = [self codableProperties];
    for (NSString *key in properties) {
        id object = nil;
        Class propertyClass = properties[key];
        if (secureAvailable) {
            object = [aDecoder decodeObjectOfClass:propertyClass forKey:key];
        }
        else {
            object = [aDecoder decodeObjectForKey:key];
        }
        if (object) {
            if (secureSupported && ![object isKindOfClass:propertyClass]) {
                [NSException raise:@"MApiException" format:@"Expected '%@' to be a %@, but was actually a %@", key, propertyClass, [object class]];
            }
            [self setValue:object forKey:key];
        }
    }
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    @try {
        id copy = [[self.class allocWithZone:zone] init];
        [copy setValuesForKeysWithDictionary:[self dictionaryRepresentation:NO]];
        return copy;
    } @catch (NSException *exception) {
        return nil;
    }
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    @try {
        [self setWithCoder:aDecoder];
        return self;
    } @catch (NSException *exception) {
        return nil;
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    @try {
        for (NSString *key in [self codableProperties]) {
            id object = [self valueForKey:key];
            if (object) [aCoder encodeObject:object forKey:key];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
}

@end
