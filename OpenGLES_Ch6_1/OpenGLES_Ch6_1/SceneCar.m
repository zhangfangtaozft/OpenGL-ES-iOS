//
//  SceneCar.m
//  OpenGLES_Ch6_1
//
//  Created by frank.zhang on 2019/2/12.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import "SceneCar.h"


@interface SceneCar ()

@property (strong, nonatomic, readwrite) SceneModel
*model;
@property (assign, nonatomic, readwrite) GLKVector3
position;
@property (assign, nonatomic, readwrite) GLKVector3
nextPosition;
@property (assign, nonatomic, readwrite) GLKVector3
velocity;
@property (assign, nonatomic, readwrite) GLfloat
yawRadians;
@property (assign, nonatomic, readwrite) GLfloat
targetYawRadians;
@property (assign, nonatomic, readwrite) GLKVector4
color;
@property (assign, nonatomic, readwrite) GLfloat
radius;

@end


@implementation SceneCar

@synthesize model;
@synthesize position;
@synthesize velocity;
@synthesize yawRadians;
@synthesize targetYawRadians;
@synthesize color;
@synthesize nextPosition;
@synthesize radius;

- (id)init
{
    NSAssert(0, @"Invalid initializer");
    self = nil;
    return self;
}

- (id)initWithModel:(SceneModel *)aModel
           position:(GLKVector3)aPosition
           velocity:(GLKVector3)aVelocity
              color:(GLKVector4)aColor;
{
    if(nil != (self = [super init]))
    {
        self.position = aPosition;
        self.color = aColor;
        self.velocity = aVelocity;
        self.model = aModel;
        SceneAxisAllignedBoundingBox axisAlignedBoundingBox =
        self.model.axisAlignedBoundingBox;
        self.radius = 0.5f * MAX(axisAlignedBoundingBox.max.x -
                                 axisAlignedBoundingBox.min.x,
                                 axisAlignedBoundingBox.max.z -
                                 axisAlignedBoundingBox.min.z);
    }
    return self;
}

- (void)bounceOffWallsWithBoundingBox:
(SceneAxisAllignedBoundingBox)rinkBoundingBox
{
    if((rinkBoundingBox.min.x + self.radius) >
       self.nextPosition.x)
    {
        self.nextPosition = GLKVector3Make(
                                           (rinkBoundingBox.min.x + self.radius),
                                           self.nextPosition.y, self.nextPosition.z);
        self.velocity = GLKVector3Make(-self.velocity.x,
                                       self.velocity.y, self.velocity.z);
    }
    else if((rinkBoundingBox.max.x - self.radius) <
            self.nextPosition.x)
    {
        self.nextPosition = GLKVector3Make(
                                           (rinkBoundingBox.max.x - self.radius),
                                           self.nextPosition.y, self.nextPosition.z);
        self.velocity = GLKVector3Make(-self.velocity.x,
                                       self.velocity.y, self.velocity.z);
    }
    
    if((rinkBoundingBox.min.z + self.radius) >
       self.nextPosition.z)
    {
        self.nextPosition = GLKVector3Make(self.nextPosition.x,
                                           self.nextPosition.y,
                                           (rinkBoundingBox.min.z + self.radius));
        self.velocity = GLKVector3Make(self.velocity.x,
                                       self.velocity.y, -self.velocity.z);
    }
    else if((rinkBoundingBox.max.z - self.radius) <
            self.nextPosition.z)
    {
        self.nextPosition = GLKVector3Make(self.nextPosition.x,
                                           self.nextPosition.y,
                                           (rinkBoundingBox.max.z - self.radius));
        self.velocity = GLKVector3Make(self.velocity.x,
                                       self.velocity.y, -self.velocity.z);
    }
}

- (void)bounceOffCars:(NSArray *)cars
          elapsedTime:(NSTimeInterval)elapsedTimeSeconds
{
    for(SceneCar *currentCar in cars)
    {
        if(currentCar != self)
        {
            float    distance = GLKVector3Distance(
                                                   self.nextPosition, currentCar.nextPosition);
            if((2.0f * self.radius) > distance)
            {
                GLKVector3 ownVelocity = self.velocity;
                GLKVector3 otherVelocity = currentCar.velocity;
                GLKVector3 directionToOtherCar = GLKVector3Subtract(
                                                                    currentCar.position,
                                                                    self.position);
                
                directionToOtherCar = GLKVector3Normalize(
                                                          directionToOtherCar);
                GLKVector3 negDirectionToOtherCar =
                GLKVector3Negate(directionToOtherCar);
                
                GLKVector3 tanOwnVelocity = GLKVector3MultiplyScalar(
                                                                     negDirectionToOtherCar, GLKVector3DotProduct(
                                                                                                                  ownVelocity, negDirectionToOtherCar));
                GLKVector3 tanOtherVelocity = GLKVector3MultiplyScalar(
                                                                       directionToOtherCar, GLKVector3DotProduct(
                                                                                                                 otherVelocity, directionToOtherCar));
                
                {
                    self.velocity = GLKVector3Subtract(
                                                       ownVelocity,
                                                       tanOwnVelocity);
                    
                    GLKVector3 travelDistance =
                    GLKVector3MultiplyScalar(self.velocity,
                                             elapsedTimeSeconds);
                    
                    self.nextPosition = GLKVector3Add(self.position,
                                                      travelDistance);
                }
                
                {
                    currentCar.velocity = GLKVector3Subtract(
                                                             otherVelocity,
                                                             tanOtherVelocity);
                    
                    GLKVector3 travelDistance =
                    GLKVector3MultiplyScalar(currentCar.velocity,
                                             elapsedTimeSeconds);
                    currentCar.nextPosition = GLKVector3Add(
                                                            currentCar.position,
                                                            travelDistance);
                }
            }
        }
    }
}


- (void)spinTowardDirectionOfMotion:(NSTimeInterval)elapsed
{
    self.yawRadians = SceneScalarSlowLowPassFilter(
                                                   elapsed,
                                                   self.targetYawRadians,
                                                   self.yawRadians);
}

- (void)updateWithController:
(id <SceneCarControllerProtocol>)controller;
{
    NSTimeInterval   elapsedTimeSeconds =
    MIN(MAX([controller timeSinceLastUpdate], 0.01f), 0.5f);
    GLKVector3 travelDistance =
    GLKVector3MultiplyScalar(self.velocity,
                             elapsedTimeSeconds);
    
    self.nextPosition = GLKVector3Add(self.position,
                                      travelDistance);
    
    SceneAxisAllignedBoundingBox rinkBoundingBox =
    [controller rinkBoundingBox];
    
    [self bounceOffCars:[controller cars]
            elapsedTime:elapsedTimeSeconds];
    [self bounceOffWallsWithBoundingBox:rinkBoundingBox];
    if(0.1 > GLKVector3Length(self.velocity))
    {
        self.velocity = GLKVector3Make(
                                       (random() / (0.5f * RAND_MAX)) - 1.0f,
                                       0.0f,
                                       (random() / (0.5f * RAND_MAX)) - 1.0f);
    }
    else if(4 > GLKVector3Length(self.velocity))
    {
        self.velocity = GLKVector3MultiplyScalar(
                                                 self.velocity,
                                                 1.01f);
    }
    float dotProduct = GLKVector3DotProduct(
                                            GLKVector3Normalize(self.velocity),
                                            GLKVector3Make(0.0, 0, -1.0));

    if(0.0 > self.velocity.x)
    {
        self.targetYawRadians = acosf(dotProduct);
    }
    else
    {
        self.targetYawRadians = -acosf(dotProduct);
    }
    [self spinTowardDirectionOfMotion:elapsedTimeSeconds];
    self.position = self.nextPosition;
}

/*
 下面这个方法会设置当前材质的颜色以匹配碰碰车的颜色，平移model-view坐标系到碰碰车的当前位置，旋转坐标系以匹配碰碰车的颜色，平移model-view坐标系到碰碰车的当前位置，旋转坐标系以匹配碰碰车的当前偏航角，并且绘制碰碰车模型。
 */
- (void)drawWithBaseEffect:(GLKBaseEffect *)anEffect;
{
    GLKMatrix4  savedModelviewMatrix =
    anEffect.transform.modelviewMatrix;
    GLKVector4  savedDiffuseColor =
    anEffect.material.diffuseColor;
    GLKVector4  savedAmbientColor =
    anEffect.material.ambientColor;

    anEffect.transform.modelviewMatrix =
    GLKMatrix4Translate(savedModelviewMatrix,
                        position.x, position.y, position.z);
    
    anEffect.transform.modelviewMatrix =
    GLKMatrix4Rotate(anEffect.transform.modelviewMatrix,
                     self.yawRadians,
                     0.0, 1.0, 0.0);
    anEffect.material.diffuseColor = self.color;
    anEffect.material.ambientColor = self.color;
    [anEffect prepareToDraw];
    [model draw];
    anEffect.transform.modelviewMatrix = savedModelviewMatrix;
    anEffect.material.diffuseColor = savedDiffuseColor;
    anEffect.material.ambientColor = savedAmbientColor;
}

@end

GLfloat SceneScalarFastLowPassFilter(
                                     NSTimeInterval elapsed,    // seconds elapsed since last call
                                     GLfloat target,            // target value to approach
                                     GLfloat current)           // current value
{
    return current + (50.0 * elapsed * (target - current));
}

GLfloat SceneScalarSlowLowPassFilter(
                                     NSTimeInterval elapsed,    // seconds elapsed since last call
                                     GLfloat target,            // target value to approach
                                     GLfloat current)           // current value
{
    return current + (4.0 * elapsed * (target - current));
}


GLKVector3 SceneVector3FastLowPassFilter(
                                         NSTimeInterval elapsed,    // seconds elapsed since last call
                                         GLKVector3 target,         // target value to approach
                                         GLKVector3 current)        // current value
{
    return GLKVector3Make(
                          SceneScalarFastLowPassFilter(elapsed, target.x, current.x),
                          SceneScalarFastLowPassFilter(elapsed, target.y, current.y),
                          SceneScalarFastLowPassFilter(elapsed, target.z, current.z));
}


GLKVector3 SceneVector3SlowLowPassFilter(
                                         NSTimeInterval elapsed,    // seconds elapsed since last call
                                         GLKVector3 target,         // target value to approach
                                         GLKVector3 current)        // current value
{
    return GLKVector3Make(
                          SceneScalarSlowLowPassFilter(elapsed, target.x, current.x),
                          SceneScalarSlowLowPassFilter(elapsed, target.y, current.y),
                          SceneScalarSlowLowPassFilter(elapsed, target.z, current.z));
}


