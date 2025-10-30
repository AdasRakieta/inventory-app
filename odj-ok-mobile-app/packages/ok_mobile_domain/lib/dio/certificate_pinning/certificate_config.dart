part of '../../ok_mobile_domain.dart';

abstract class CertificateConfig {
  List<String> get allowedSHA256Fingerprints;
  bool get isPinningEnabled;
}

class PrdCertificateConfig extends CertificateConfig {
  @override
  List<String> get allowedSHA256Fingerprints => [
    // Production server SHA256 fingerprint
    'A57F959061E41C13A0056533F3CE8E074B1DB1E2249635B4AFECF1D6844D4F3',
    'cb981febb9bd43e80b5b41ea60ca3404db86f0d7752b6cf4ff806022171535a5',
    // Lidl Proxy Fingerprint
    'db1c427ce3bdc310ba6006fb0b18c32e454feba96bfcf19019fcb7b08ce24e02',
  ];

  @override
  bool get isPinningEnabled => true;
}

class DevCertificateConfig extends CertificateConfig {
  DevCertificateConfig();
  @override
  List<String> get allowedSHA256Fingerprints => [
    // Development server SHA256 fingerprint
    'AF7A26CF8EACAC6E3FE4994440948B5B77649A976F064C65EA9CB72FCCF9D763',
    // Lidl Proxy Fingerprint
    '1d0e5fa736be19dc70ed201919a5f2084afeb49c8c3998e5fef8e8500709a0d8',
  ];

  @override
  bool get isPinningEnabled => true;
}

class TstCertificateConfig extends CertificateConfig {
  @override
  List<String> get allowedSHA256Fingerprints => [
    // Test server SHA256 fingerprint
    'BE849DE90C2F0E4FD03AD51F0D3C66646A054A3EBF5A4622CD257DA05A8F72D0',
    // Lidl Proxy Fingerprint
    'e9894a25655785c885aa809b39c73a8b1052d629b14cbb8ddc938228cf1ea720',
  ];

  @override
  bool get isPinningEnabled => true;
}

class UatCertificateConfig extends CertificateConfig {
  @override
  List<String> get allowedSHA256Fingerprints => [
    // UAT server SHA256 fingerprint
    'ADF9B6EEE03984D062B95E2F19E6F07EAB5C177021D61811F853557E42160A21',
    // Lidl Proxy Fingerprint
    'b3007eb257704013e5295563428962709f6d8a0c9e3f5686572a0a2699a7d513',
  ];

  @override
  bool get isPinningEnabled => true;
}

class OfflineCertificateConfig extends CertificateConfig {
  @override
  List<String> get allowedSHA256Fingerprints => [];

  @override
  bool get isPinningEnabled => false;
}
