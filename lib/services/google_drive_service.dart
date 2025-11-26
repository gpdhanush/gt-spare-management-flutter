import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'auth_service.dart';
import 'database_helper.dart';

class GoogleDriveService {
  static final GoogleDriveService instance = GoogleDriveService._init();
  GoogleDriveService._init();

  static const String _dbFileName = 'spare_management.db';
  static const String _driveFolderName = 'Spare Management';

  Future<drive.DriveApi?> _getDriveApi() async {
    try {
      final accessToken = await AuthService.instance.getAccessToken();
      if (accessToken == null) {
        return null;
      }

      final credentials = AccessCredentials(
        AccessToken(
          'Bearer',
          accessToken,
          DateTime.now().add(const Duration(hours: 1)),
        ),
        null,
        ['https://www.googleapis.com/auth/drive.file'],
      );

      final client = authenticatedClient(http.Client(), credentials);
      return drive.DriveApi(client);
    } catch (e) {
      debugPrint('Error getting Drive API: $e');
      return null;
    }
  }

  Future<String?> _getOrCreateFolder(drive.DriveApi driveApi) async {
    try {
      // Search for existing folder
      final response = await driveApi.files.list(
        q: "mimeType='application/vnd.google-apps.folder' and name='$_driveFolderName' and trashed=false",
        spaces: 'drive',
      );

      if (response.files != null && response.files!.isNotEmpty) {
        return response.files!.first.id;
      }

      // Create folder if it doesn't exist
      final folder = drive.File()
        ..name = _driveFolderName
        ..mimeType = 'application/vnd.google-apps.folder';

      final createdFolder = await driveApi.files.create(folder);
      return createdFolder.id;
    } catch (e) {
      debugPrint('Error getting/creating folder: $e');
      return null;
    }
  }

  Future<String?> _findExistingFile(
    drive.DriveApi driveApi,
    String folderId,
  ) async {
    try {
      final response = await driveApi.files.list(
        q: "name='$_dbFileName' and '$folderId' in parents and trashed=false",
        spaces: 'drive',
      );

      if (response.files != null && response.files!.isNotEmpty) {
        return response.files!.first.id;
      }
      return null;
    } catch (e) {
      debugPrint('Error finding existing file: $e');
      return null;
    }
  }

  Future<String> _getDatabasePath() async {
    return await DatabaseHelper.instance.getDatabasePath();
  }

  Future<bool> exportDatabase() async {
    try {
      EasyLoading.show(status: 'Exporting to Google Drive...');

      final driveApi = await _getDriveApi();
      if (driveApi == null) {
        EasyLoading.dismiss();
        EasyLoading.showError('Failed to connect to Google Drive');
        return false;
      }

      // Get or create folder
      final folderId = await _getOrCreateFolder(driveApi);
      if (folderId == null) {
        EasyLoading.dismiss();
        EasyLoading.showError('Failed to create folder in Google Drive');
        return false;
      }

      // Get database file
      final dbPath = await _getDatabasePath();
      final file = File(dbPath);
      if (!await file.exists()) {
        EasyLoading.dismiss();
        EasyLoading.showError('Database file not found');
        return false;
      }

      final fileBytes = await file.readAsBytes();

      // Check if file already exists
      final existingFileId = await _findExistingFile(driveApi, folderId);

      if (existingFileId != null) {
        // Update existing file
        final media = drive.Media(file.openRead(), fileBytes.length);
        await driveApi.files.update(
          drive.File()..name = _dbFileName,
          existingFileId,
          uploadMedia: media,
        );
      } else {
        // Create new file
        final driveFile = drive.File()
          ..name = _dbFileName
          ..parents = [folderId];

        final media = drive.Media(file.openRead(), fileBytes.length);
        await driveApi.files.create(driveFile, uploadMedia: media);
      }

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Database exported successfully!');
      return true;
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Export failed: ${e.toString()}');
      return false;
    }
  }

  Future<bool> importDatabase({bool replaceExisting = false}) async {
    try {
      EasyLoading.show(status: 'Importing from Google Drive...');

      final driveApi = await _getDriveApi();
      if (driveApi == null) {
        EasyLoading.dismiss();
        EasyLoading.showError('Failed to connect to Google Drive');
        return false;
      }

      // Get folder
      final folderId = await _getOrCreateFolder(driveApi);
      if (folderId == null) {
        EasyLoading.dismiss();
        EasyLoading.showError('Folder not found in Google Drive');
        return false;
      }

      // Find file
      final fileId = await _findExistingFile(driveApi, folderId);
      if (fileId == null) {
        EasyLoading.dismiss();
        EasyLoading.showError('Database file not found in Google Drive');
        return false;
      }

      // Download file
      final response =
          await driveApi.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final bytes = <int>[];
      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
      }

      // Save to local database
      final dbPath = await _getDatabasePath();
      final file = File(dbPath);

      if (await file.exists() && !replaceExisting) {
        // Backup existing database
        final backupPath = '${dbPath}.backup';
        await file.copy(backupPath);
      }

      await file.writeAsBytes(bytes);

      // Close and reinitialize database
      await DatabaseHelper.instance.closeDatabase();
      await DatabaseHelper.instance.database; // Reinitialize

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Database imported successfully!');
      return true;
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Import failed: ${e.toString()}');
      return false;
    }
  }
}
