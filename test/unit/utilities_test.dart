import 'package:flutter_test/flutter_test.dart';
import 'package:notevault/core/extensions/date_extensions.dart';
import 'package:notevault/core/extensions/string_extensions.dart';
import 'package:notevault/core/utils/validators.dart';
import 'package:notevault/services/security_service.dart';

void main() {
  group('String & Text Extensions Tests', () {
    test('calculates word count accurately for empty, single, and multiple words', () {
      expect(''.wordCount, 0);
      expect('   '.wordCount, 0);
      expect('NoteVault'.wordCount, 1);
      expect('Organize your thoughts, tasks, and ideas.'.wordCount, 6);
      expect('Multi\nline\ttext with   multiple   spaces'.wordCount, 6);
    });

    test('calculates reading time estimates correctly', () {
      expect('Short note'.readingTimeFormatted, '< 1 min read');

      final longText = List.generate(450, (index) => 'word$index').join(' ');
      expect(longText.readingTimeFormatted, '3 min read');
    });

    test('character count returns total non-empty length', () {
      expect('Hello World'.charCount, 11);
      expect(''.charCount, 0);
    });
  });

  group('Date Extensions & Trash Expiry Tests', () {
    test('formats dates cleanly', () {
      final date = DateTime(2026, 10, 27, 14, 30);
      expect(date.formatDate(), contains('Oct 27, 2026'));
      expect(date.formatTime(), contains('2:30'));
    });

    test('calculates 30-day trash expiry countdown correctly', () {
      final deletedNow = DateTime.now();
      expect(deletedNow.daysRemainingInTrash(), 30);

      final deleted10DaysAgo = DateTime.now().subtract(const Duration(days: 10));
      expect(deleted10DaysAgo.daysRemainingInTrash(), 20);

      final deleted31DaysAgo = DateTime.now().subtract(const Duration(days: 31));
      expect(deleted31DaysAgo.daysRemainingInTrash(), 0);
    });
  });

  group('Validators Tests', () {
    test('validates note titles and content properly', () {
      expect(Validators.validateFolderName(''), isNotNull);
      expect(Validators.validateFolderName('  '), isNotNull);
      expect(Validators.validateFolderName('My Project'), isNull);

      expect(Validators.isValidNote(title: '', body: ''), isFalse);
      expect(Validators.isValidNote(title: '   ', body: '   '), isFalse);
      expect(Validators.isValidNote(title: 'Valid Title', body: ''), isTrue);
      expect(Validators.isValidNote(title: '', body: 'Valid Content'), isTrue);
    });

    test('validates PIN input correctly', () {
      expect(Validators.validatePin(''), 'PIN cannot be empty');
      expect(Validators.validatePin('123', length: 4), 'PIN must be exactly 4 digits');
      expect(Validators.validatePin('12345', length: 4), 'PIN must be exactly 4 digits');
      expect(Validators.validatePin('123a', length: 4), 'PIN must contain digits only');
      expect(Validators.validatePin('1234', length: 4), isNull);
      expect(Validators.validatePin('123456', length: 6), isNull);
    });
  });

  group('Security Service PIN Hashing Tests', () {
    test('hashes PIN with SHA-256 with zero plain text storage', () {
      final hash1 = SecurityService.hashPin('1234');
      final hash2 = SecurityService.hashPin('1234');
      final hashDifferent = SecurityService.hashPin('4321');

      expect(hash1, equals(hash2));
      expect(hash1, isNot(equals('1234')));
      expect(hash1.length, 64); // SHA-256 hex string length
      expect(hash1, isNot(equals(hashDifferent)));
    });
  });
}
