class Parse {
  stringToMap(String inputString) {
    List<Map<String, dynamic>> listOfMaps = [];

    // Remove leading and trailing brackets from the input string
    String content = inputString.substring(1, inputString.length - 1);

    // Split the string into individual map strings
    List<String> mapStrings = content.split(RegExp(r'(?<=\}),\s*(?=\{)'));

    for (String mapString in mapStrings) {
      Map<String, dynamic> map = parseMap(mapString);
      listOfMaps.add(map);
    }

    return listOfMaps;
  }

  Map<String, dynamic> parseMap(String mapString) {
    Map<String, dynamic> map = {};

    mapString = mapString.replaceAll(RegExp(r'^\{|\}$'), '');

    List<String> keyValuePairs = mapString.split(RegExp(r',(?![^\[]*[\]])'));

    for (String pair in keyValuePairs) {
      List<String> keyValue = pair.split(':');

      String key = keyValue[0].trim().replaceAll(RegExp(r'^"|"$'), '');
      String value = keyValue[1].trim().replaceAll(RegExp(r'^"|"$'), '');

      map[key] = value;
    }

    return map;
  }

  intStringToDouble(String integerString) {
    double doubleValue = int.parse(integerString) / 1;
    String formattedDouble = doubleValue.toStringAsFixed(2);
    return formattedDouble;
  }

  String extractServiceNamesFromListofMap(dynamic services) {
    if (services is List<dynamic>) {
      // Handle list of maps (expected format)
      final serviceNames =
          services.map((service) => service['serviceName']).toList();
      return serviceNames
          .join(', '); // Join service names with comma and space separator
    } else if (services is Map<String, dynamic>) {
      // Handle single map (potential case)
      final serviceName = services['serviceName'];
      if (serviceName != null) {
        return serviceName; // Return single service name
      } else {
        return ''; // Return empty string if "serviceName" key is missing
      }
    } else {
      throw Exception(
          'Invalid input type: ${services.runtimeType}'); // Handle unexpected input
    }
  }
}
