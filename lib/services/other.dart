Future<bool> compareVersion(
    {required String previousVersion, required String latestVersion}) async {
  int temp1, temp2;
  temp1 = int.tryParse(previousVersion.replaceAll('.', '').toString())!;
  temp2 = int.tryParse(latestVersion.replaceAll('.', '').toString())!;
  return (temp1 < temp2) ? true : false;
}
