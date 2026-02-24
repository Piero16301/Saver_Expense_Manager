import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/models/models.dart';

void main() {
  group('Movement', () {
    const id = 'id';
    const title = 'title';
    const description = 'description';
    final date = DateTime(2023);
    const category = Category.empty;
    const price = 10.0;
    const company = 'company';
    const attachments = ['attachment'];
    const user = 'user';
    const movementRecap = 'movementRecap';

    Movement createSubject() => Movement(
          id: id,
          title: title,
          description: description,
          date: date,
          category: category,
          price: price,
          company: company,
          attachments: attachments,
          user: user,
          movementRecap: movementRecap,
        );

    test('supports value equality', () {
      expect(createSubject(), equals(createSubject()));
    });

    group('fromJson', () {
      test('returns correct Movement from populated json', () {
        final json = <String, dynamic>{
          'id': id,
          'title': title,
          'description': description,
          'date': Timestamp.fromDate(date),
          'category': category.toJson(),
          'price': price,
          'company': company,
          'attachments': attachments,
          'user': user,
          'movement_recap': movementRecap,
        };

        expect(
          Movement.fromJson(json),
          equals(createSubject()),
        );
      });

      test('returns correct Movement from empty json', () {
        final json = <String, dynamic>{
          'id': 'test_id',
        };

        final movement = Movement.fromJson(json);

        expect(movement.id, equals('test_id'));
        expect(movement.title, equals(''));
        expect(movement.description, equals(''));
        expect(movement.category, equals(Category.empty));
        expect(movement.price, equals(0.0));
        expect(movement.company, equals(''));
        expect(movement.attachments, isEmpty);
        expect(movement.user, equals(''));
        expect(movement.movementRecap, equals(''));
      });
    });

    group('fromAiService', () {
      test('parses AI response correctly', () {
        final categories = [
          const Category(
            id: '1',
            name: 'Food',
            icon: '',
            color: '',
            type: CategoryType.expense,
          ),
        ];

        final json = <String, dynamic>{
          'title': 'Lunch',
          'description': 'Burger',
          'date': '01/01/2023',
          'category': 'Food',
          'price': 15.5,
          'company': 'McDonalds',
          'movement_recap': 'Lunch at McDonalds',
        };

        final movement = Movement.fromAiService(json, categories);

        expect(movement.title, equals('Lunch'));
        expect(movement.description, equals('Burger'));
        expect(movement.date, equals(DateTime(2023)));
        expect(movement.category.name, equals('Food'));
        expect(movement.price, equals(15.5));
        expect(movement.company, equals('McDonalds'));
        expect(movement.movementRecap, equals('Lunch at McDonalds'));
        expect(movement.id, equals(''));
      });
    });

    group('toJson', () {
      test('returns correct map', () {
        final movement = createSubject();
        final json = movement.toJson();

        expect(
          json,
          equals({
            'id': id,
            'title': title,
            'description': description,
            'date': date.toUtc(),
            'category': category.toJson(),
            'price': price,
            'company': company,
            'attachments': attachments,
            'user': user,
            'movement_recap': movementRecap,
          }),
        );
      });
    });

    group('copyWith', () {
      test('returns same object if no arguments are provided', () {
        expect(createSubject().copyWith(), equals(createSubject()));
      });

      test('replaces every non-null parameter', () {
        final movement = createSubject();
        final newDate = DateTime(2023, 2, 2);
        const newCategory = Category(
          id: '2',
          name: 'test',
          icon: 'icon',
          color: 'color',
          type: CategoryType.expense,
        );

        expect(
          movement.copyWith(
            id: 'newId',
            title: 'newTitle',
            description: 'newDesc',
            date: newDate,
            category: newCategory,
            price: 20,
            company: 'newCompany',
            attachments: ['newAttachment'],
            user: 'newUser',
            movementRecap: 'newRecap',
          ),
          equals(
            Movement(
              id: 'newId',
              title: 'newTitle',
              description: 'newDesc',
              date: newDate,
              category: newCategory,
              price: 20,
              company: 'newCompany',
              attachments: const ['newAttachment'],
              user: 'newUser',
              movementRecap: 'newRecap',
            ),
          ),
        );
      });
    });
  });
}
