import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/models/models.dart';

void main() {
  group('Movement', () {
    final now = DateTime.now();
    final date = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
    );

    const category = Category(
      id: '1',
      name: 'Food',
      icon: 'fastfood',
      color: 'red',
      type: CategoryType.expense,
    );

    final movement = Movement(
      id: '1',
      title: 'Groceries',
      description: 'Weekly groceries',
      date: date,
      category: category,
      price: 50,
      user: 'user1',
      movementRecap: 'Bought milk and bread',
      company: 'Supermarket',
      attachments: const ['receipt.jpg'],
    );

    final movement2 = Movement(
      id: '1',
      title: 'Groceries',
      description: 'Weekly groceries',
      date: date,
      category: category,
      price: 50,
      user: 'user1',
      movementRecap: 'Bought milk and bread',
      company: 'Supermarket',
      attachments: const ['receipt.jpg'],
    );

    test('supports value comparisons', () {
      expect(movement, movement2);
    });

    test('props are correct', () {
      expect(
        movement.props,
        equals([
          '1',
          'Groceries',
          'Weekly groceries',
          date,
          category,
          50.0,
          'Supermarket',
          ['receipt.jpg'],
          'user1',
          'Bought milk and bread',
        ]),
      );
    });

    group('fromJson', () {
      test('returns correct object from valid json', () {
        final timestamp = Timestamp.fromDate(date);
        final json = {
          'id': '1',
          'title': 'Groceries',
          'description': 'Weekly groceries',
          'date': timestamp,
          'category': category.toJson(),
          'price': 50.0,
          'company': 'Supermarket',
          'attachments': ['receipt.jpg'],
          'user': 'user1',
          'movement_recap': 'Bought milk and bread',
        };

        final result = Movement.fromJson(json);
        expect(result.id, movement.id);
        expect(result.title, movement.title);
        expect(result.date.isAtSameMomentAs(movement.date), isTrue);
        expect(result.category, movement.category);
        expect(result.price, movement.price);
        expect(result.company, movement.company);
        expect(result.attachments, movement.attachments);
        expect(result.user, movement.user);
        expect(result.movementRecap, movement.movementRecap);
      });

      test('returns default object when json keys are missing', () {
        final json = {
          'id': '1',
        };
        final result = Movement.fromJson(json);
        expect(result.id, '1');
        expect(result.title, '');
        expect(result.price, 0.0);
        expect(result.attachments, isEmpty);
        expect(
          result.category,
          Category.empty,
        );
      });

      test('handles int price and attachments list correctly', () {
        final json = {
          'id': '1',
          'price': 100,
          'attachments': ['img1.png', null],
        };
        final result = Movement.fromJson(json);
        expect(result.price, 100.0);
        expect(result.attachments, ['img1.png', '']);
      });
    });

    group('fromAiService', () {
      test('returns correct object from valid AI service json', () {
        final json = {
          'category': 'Food',
          'id': 'ai_1',
          'title': 'AI Title',
          'description': 'AI Desc',
          'date': '16/02/2026',
          'price': 25.5,
          'company': 'AI Company',
          'movement_recap': 'AI Recap',
        };

        final categories = [category];

        final expectedDate = DateTime(2026, 2, 16);

        final result = Movement.fromAiService(json, categories);

        expect(result.category, category);
        expect(result.id, 'ai_1');
        expect(result.title, 'AI Title');
        expect(result.date, expectedDate);
        expect(result.price, 25.5);
        expect(result.user, '');
      });

      test('returns empty category if not found in list', () {
        final json = {
          'category': 'Unknown',
          'date': '01/01/2026',
        };
        final result = Movement.fromAiService(json, const [category]);
        expect(result.category, Category.empty);
      });
    });

    group('toJson', () {
      test('returns correct map', () {
        final expectedJson = {
          'id': '1',
          'title': 'Groceries',
          'description': 'Weekly groceries',
          'date': date.toUtc(),
          'category': category.toJson(),
          'price': 50.0,
          'company': 'Supermarket',
          'attachments': ['receipt.jpg'],
          'user': 'user1',
          'movement_recap': 'Bought milk and bread',
        };

        expect(movement.toJson(), expectedJson);
      });
    });

    group('copyWith', () {
      test('returns same object if no arguments provided', () {
        expect(movement.copyWith(), movement);
      });

      test('returns updated object with provided arguments', () {
        final updated = movement.copyWith(
          title: 'New Title',
          price: 99.9,
        );
        expect(updated.title, 'New Title');
        expect(updated.price, 99.9);
        expect(updated.id, movement.id);
      });
    });

    test('empty returns correct default values', () {
      final empty = Movement.empty;
      expect(empty.id, '');
      expect(empty.title, '');
      expect(empty.price, 0);
      expect(empty.date, isA<DateTime>());
      expect(empty.category, Category.empty);
    });
  });
}
