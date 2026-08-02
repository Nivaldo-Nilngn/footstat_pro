import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:js' as js;

class SoundEffects {
  /// Blows a realistic referee whistle sound (sound synthesis) and triggers heavy device vibration
  static void playWhistle() {
    // 1. Heavy Device Haptic Vibration Sequence
    try {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 150), () {
        HapticFeedback.vibrate();
      });
      Future.delayed(const Duration(milliseconds: 350), () {
        HapticFeedback.heavyImpact();
      });
    } catch (_) {}

    // 2. System Alert Sound
    try {
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}

    // 3. Web Audio API Referee Whistle Synthesizer (Double Whistle PII! PIII!)
    if (kIsWeb) {
      try {
        js.context.callMethod('eval', [
          '''
          (function() {
            try {
              var ctx = new (window.AudioContext || window.webkitAudioContext)();
              if (ctx.state === 'suspended') {
                ctx.resume();
              }
              
              function blow(freq, start, duration) {
                var osc = ctx.createOscillator();
                var gain = ctx.createGain();
                osc.type = 'sine';
                osc.frequency.setValueAtTime(freq, ctx.currentTime + start);
                
                var lfo = ctx.createOscillator();
                lfo.frequency.value = 35;
                var lfoGain = ctx.createGain();
                lfoGain.gain.value = 180;
                lfo.connect(osc.frequency);
                lfo.start(ctx.currentTime + start);
                lfo.stop(ctx.currentTime + start + duration);

                gain.gain.setValueAtTime(0.35, ctx.currentTime + start);
                gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + start + duration);

                osc.connect(gain);
                gain.connect(ctx.destination);

                osc.start(ctx.currentTime + start);
                osc.stop(ctx.currentTime + start + duration);
              }

              // Double Whistle: PII! PIIII!
              blow(2100, 0.0, 0.3);
              blow(2350, 0.4, 0.7);
            } catch(e) {}
          })();
          '''
        ]);
      } catch (_) {}
    }
  }

  /// Plays a short tick sound & medium vibration when time is ending
  static void playWarningTick() {
    try {
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}

    if (kIsWeb) {
      try {
        js.context.callMethod('eval', [
          '''
          (function() {
            try {
              var ctx = new (window.AudioContext || window.webkitAudioContext)();
              if (ctx.state === 'suspended') {
                ctx.resume();
              }
              var osc = ctx.createOscillator();
              var gain = ctx.createGain();
              osc.type = 'sine';
              osc.frequency.value = 1200;
              gain.gain.setValueAtTime(0.15, ctx.currentTime);
              gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.12);
              osc.connect(gain);
              gain.connect(ctx.destination);
              osc.start();
              osc.stop(ctx.currentTime + 0.12);
            } catch(e) {}
          })();
          '''
        ]);
      } catch (_) {}
    }
  }
}
