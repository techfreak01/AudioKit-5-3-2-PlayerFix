// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

extension AudioPlayer {
    /// Schedule a file or buffer. You can call this to schedule playback in the future
    /// or the player will call it when play() is called to load the audio data
    /// - Parameters:
    ///   - when: What time to schedule for
    ///   - completionCallbackType: Constants that specify when the completion handler must be invoked.
    public func schedule(at when: AVAudioTime? = nil,
                         completionCallbackType: AVAudioPlayerNodeCompletionCallbackType = .dataPlayedBack) {
        status = .scheduling

        if isBuffered {
            updateBuffer()
            Task {
                await scheduleBuffer(at: when,
                                     completionCallbackType: completionCallbackType)
            }

        } else if file != nil {
            Task {
                await scheduleSegment(at: when,
                                      completionCallbackType: completionCallbackType)
            }

        } else {
            Log("The player needs a file or a valid buffer to schedule", type: .error)
        }
    }

    // play from disk rather than ram
    private func scheduleSegment(at audioTime: AVAudioTime?,
                                 completionCallbackType: AVAudioPlayerNodeCompletionCallbackType = .dataPlayedBack) async {
        guard let file = file else {
            Log("File is nil")
            return
        }

        let startFrame = AVAudioFramePosition(editStartTime * file.fileFormat.sampleRate)
        var endFrame = AVAudioFramePosition(editEndTime * file.fileFormat.sampleRate)

        if endFrame == 0 {
            endFrame = file.length
        }

        let totalFrames = (file.length - startFrame) - (file.length - endFrame)

        guard totalFrames > 0 else {
            Log("Unable to schedule file. totalFrames to play: \(totalFrames). file.length: \(file.length)", type: .error)
            return
        }

        let frameCount = AVAudioFrameCount(totalFrames)

        await playerNode.scheduleSegment(file,
                                   startingFrame: startFrame,
                                   frameCount: frameCount,
                                   at: audioTime)

        if isSeeking { return }
        await internalCompletionHandler()

        playerNode.prepare(withFrameCount: frameCount)
    }

    private func scheduleBuffer(at audioTime: AVAudioTime?,
                                completionCallbackType: AVAudioPlayerNodeCompletionCallbackType = .dataPlayedBack) async {
        if playerNode.outputFormat(forBus: 0) != buffer?.format {
            Log("Format of the buffer doesn't match the player")
            Log("Player", playerNode.outputFormat(forBus: 0), "Buffer", buffer?.format)
            updateBuffer(force: true)
        }

        guard let buffer = buffer else {
            Log("Failed to fill buffer")
            return
        }

        var bufferOptions: AVAudioPlayerNodeBufferOptions = [.interrupts]

        if isLooping {
            bufferOptions = [.loops, .interrupts]
        }

        await playerNode.scheduleBuffer(buffer,
                                  at: audioTime,
                                  options: bufferOptions)

        if isSeeking { return }
        await internalCompletionHandler()

        playerNode.prepare(withFrameCount: buffer.frameLength)
    }
}
