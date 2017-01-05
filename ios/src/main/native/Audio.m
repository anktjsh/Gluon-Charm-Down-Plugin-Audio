/*
 * Copyright (c) 2016, Gluon
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL GLUON BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "Audio.h"

// Audio
Audio *_audio;

JNIEXPORT void JNICALL Java_com_gluonhq_charm_down_plugins_ios_IOSAudioService_nativePlay
(JNIEnv *env, jclass jClass, jstring jTitle)
{
    NSLog(@"Play audio");
    const jchar *charsTitle = (*env)->GetStringChars(env, jTitle, NULL);
    NSString *name = [NSString stringWithCharacters:(UniChar *)charsTitle length:(*env)->GetStringLength(env, jTitle)];
    (*env)->ReleaseStringChars(env, jTitle, charsTitle);

    _audio = [[Audio alloc] init];
    [_audio playAudio:name];
    return;
}

JNIEXPORT void JNICALL Java_com_gluonhq_charm_down_plugins_ios_IOSAudioService_nativePause
(JNIEnv *env, jclass jClass)
{
    if (_audio) 
    {
        [_audio pauseAudio];
    }
    return;   
}

JNIEXPORT void JNICALL Java_com_gluonhq_charm_down_plugins_ios_IOSAudioService_nativeResume
(JNIEnv *env, jclass jClass)
{
    if (_audio) 
    {
        [_audio resumeAudio];
    }
    return;   
}

JNIEXPORT void JNICALL Java_com_gluonhq_charm_down_plugins_ios_IOSAudioService_nativeStop
(JNIEnv *env, jclass jClass)
{
    if (_audio) 
    {
        [_audio stopAudio];
    }
    return;   
}

@implementation Audio 

AVAudioPlayer* player;

- (void)playAudio:(NSString *) audioName 
{
    NSString* fileName = [audioName stringByDeletingPathExtension];
    NSString* extension = [audioName pathExtension];

    NSURL* url = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"%@",fileName] withExtension:[NSString stringWithFormat:@"%@",extension]];
    NSError* error = nil;

    if(player)
    {
        [player stop];
        player = nil;
    }
    AVAudioSession *session = [AVAudioSession sharedInstance]; 
    [session setCategory:AVAudioSessionCategoryPlayback error:&error]; 
    [session setActive:YES error:nil];

    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if(!player)
    {
        NSLog(@"Error creating player: %@", error);
        return;
    }
    player.delegate = self;
    [player prepareToPlay];
    [player play];

}

- (void)pauseAudio
{
    if(!player)
    {
        return;
    }
    [player pause];
}

- (void)resumeAudio
{
    if(!player)
    {
        return;
    }
    [player play];
}

- (void)stopAudio
{
    if(!player)
    {
        return;
    }
    [player stop];
    player = nil;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"%s successfully=%@", __PRETTY_FUNCTION__, flag ? @"YES"  : @"NO");
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"%s error=%@", __PRETTY_FUNCTION__, error);
}

@end

