class LgpdConstants {
  static const String currentVersion = '1.0';

  static const String consentText =
      'Li e concordo com o tratamento dos meus dados pessoais e dados sensíveis '
      '(incluindo dados de saúde) conforme a Lei Geral de Proteção de Dados (LGPD - Lei 13.709/2018). '
      'Meus dados serão utilizados exclusivamente para fins de atendimento de saúde.';

  static const String aiDisclaimer =
      'AVISO IMPORTANTE: As recomendações fornecidas por IA são apenas orientativas '
      'e NÃO substituem avaliação médica profissional nem consultoria de plano de saúde. '
      'Confirme sempre a cobertura diretamente com a operadora ou hospital antes de tomar decisões.';

  static const String dataDeletionNotice =
      'Ao solicitar a exclusão, seus dados pessoais serão anonimizados. '
      'Dados de prontuário médico serão mantidos por obrigação legal (Resolução CFM 1821/2007).';

  static const List<String> requiredConsentItems = [
    'Consinto com o tratamento dos meus dados pessoais',
    'Consinto com o tratamento dos meus dados sensíveis de saúde',
    'Entendo que posso solicitar exclusão a qualquer momento',
  ];
}
