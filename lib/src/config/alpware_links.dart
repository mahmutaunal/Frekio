abstract final class AlpWareLinks {
  static final website = Uri.https('www.alpwarestudio.com');
  static final privacy = Uri.https('www.alpwarestudio.com', '/privacy');
  static final support = Uri(
    scheme: 'mailto',
    path: 'contact@alpwarestudio.com',
    queryParameters: {'subject': 'Frekio Support'},
  );
}
