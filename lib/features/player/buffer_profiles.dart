import '../../data/local/models/app_settings.dart';

const _mib = 1024 * 1024;

/// Tradução de cada [BufferProfile] em propriedades nativas do mpv,
/// aplicadas antes de abrir o stream.
///
/// * `cache-pause-initial` + `cache-pause-wait`: o pré-buffer propriamente
///   dito; o player só arranca quando tiver N segundos em cache.
/// * `cache-secs`: quanto tentar manter em cache durante a reprodução. É
///   esta reserva que absorve quebras de débito e traffic shaping do ISP.
/// * `demuxer-max-bytes`: teto em bytes para essa reserva (15 s de um
///   stream 4K a 25 Mb/s são ~47 MB).
/// * `demuxer-max-back-bytes`: cache para trás. Em direto não se volta
///   atrás, por isso é pequena: é memória poupada.
/// * `stream-lavf-o` reconnect: o ffmpeg volta a ligar sozinho quando a
///   operadora corta a ligação a meio, em vez de o stream morrer.
extension BufferProfileMpv on BufferProfile {
  String get label => switch (this) {
    BufferProfile.fast => 'Rápido',
    BufferProfile.normal => 'Normal',
    BufferProfile.stable => 'Estável (anti-bloqueio)',
  };

  String get description => switch (this) {
    BufferProfile.fast =>
      'Buffer de 1–2 s. Zapping quase instantâneo; sensível a quebras de '
          'ligação.',
    BufferProfile.normal => 'Buffer de 3–5 s. Equilíbrio entre arranque e '
        'estabilidade.',
    BufferProfile.stable =>
      'Buffer de 10–15 s. Arranque mais lento, mas resiste a quebras de '
          'velocidade e ao traffic shaping das operadoras.',
  };

  Map<String, String> mpvProperties({required bool live}) {
    final (:pauseWait, :cacheSecs, :maxBytes, :timeout, :reconnectDelay) =
        switch (this) {
          BufferProfile.fast => (
            pauseWait: 1,
            cacheSecs: 2,
            maxBytes: 32 * _mib,
            timeout: 8,
            reconnectDelay: 2,
          ),
          BufferProfile.normal => (
            pauseWait: 3,
            cacheSecs: 5,
            maxBytes: 64 * _mib,
            timeout: 10,
            reconnectDelay: 4,
          ),
          BufferProfile.stable => (
            pauseWait: 10,
            cacheSecs: 15,
            maxBytes: 160 * _mib,
            timeout: 20,
            reconnectDelay: 10,
          ),
        };

    return {
      'cache': 'yes',
      // No Rápido não se espera pelo buffer: arranca com o primeiro frame.
      'cache-pause-initial': this == BufferProfile.fast ? 'no' : 'yes',
      'cache-pause-wait': '$pauseWait',
      'cache-secs': '$cacheSecs',
      'demuxer-readahead-secs': '$cacheSecs',
      'demuxer-max-bytes': '$maxBytes',
      'demuxer-max-back-bytes': '${live ? 4 * _mib : 32 * _mib}',
      'network-timeout': '$timeout',
      'stream-lavf-o':
          'reconnect=1,reconnect_streamed=1,reconnect_on_network_error=1,'
          'reconnect_delay_max=$reconnectDelay',
    };
  }
}
