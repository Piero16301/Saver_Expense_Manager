String? highResPicture(String? url) {
  if (url == null) return null;
  return url.replaceAll('s96-c', 's400-c');
}
