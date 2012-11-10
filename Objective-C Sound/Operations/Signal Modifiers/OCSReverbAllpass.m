//
//  OCSReverbAllpass.m
//  Objective-C Sound
//
//  Created by Adam Boulanger on 10/12/12.
//  Copyright (c) 2012 Adam Boulanger. All rights reserved.
//

#import "OCSReverbAllpass.h"

@interface OCSReverbAllpass ()
{
    OCSAudio *asig;
    OCSControl *krvt;
    OCSConstant *ilpt;
    OCSConstant *iskip;
    OCSConstant *insmps;
}
@end

@implementation OCSReverbAllpass

-(id)initWithSourceAudio:(OCSAudio *)sourceAudio
       reverberationTime:(OCSControl *)reverberationTime
                loopTime:(OCSConstant *)loopTime;
{
    return [self initWithSourceAudio:sourceAudio
                   reverberationTime:reverberationTime
                            loopTime:loopTime
                    initialDelayTime:ocspi(0)
                         delayAmount:ocspi(0)];
}

-(id)initWithSourceAudio:(OCSAudio *)sourceAudio
       reverberationTime:(OCSControl *)reverberationTime
                loopTime:(OCSConstant *)loopTime
        initialDelayTime:(OCSConstant *)initialDelayTime
             delayAmount:(OCSConstant *)delayAmount;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = sourceAudio;
        krvt = reverberationTime;
        ilpt = loopTime;
        iskip = initialDelayTime;
        insmps = delayAmount;
    }
    return self;
}

// Csound prototype: ares alpass asig, krvt, ilpt [, iskip] [, insmps]
- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ alpass %@, %@, %@, %@, %@",
            self, asig, krvt, ilpt, iskip, insmps];
}

@end
