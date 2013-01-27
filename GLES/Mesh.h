//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IndexBuffer.h"
#import "VertexBuffer.h"

@interface Mesh : NSObject
{
    
}
- (void)setVertexBuffer:(VertexBuffer*)v;

- (void)setIndexBuffer:(IndexBuffer*)i;

- (void)draw;

@end
