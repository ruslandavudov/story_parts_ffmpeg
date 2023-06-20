part of story_converter;

/// Исключение при провале получения медиа-информации средствами **[FFprobeKit]**
class MediaInformationException implements Exception {}

/// Исключение для не существующего файла
class FileNotExistsException implements Exception {}
