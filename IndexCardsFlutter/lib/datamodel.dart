import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class IndexCard {
  String fronttext;
  String backtext;

  IndexCard({required this.fronttext, required this.backtext});

  factory IndexCard.fromMap(Map<String, dynamic> json) =>
      IndexCard(fronttext: json["front"], backtext: json["back"]);

  Map<String, dynamic> toMap() {
    return {"front": fronttext, "back": backtext};
  }

  @override
  String toString() {
    return "Card{fronttext: $fronttext, backtext: $backtext}";
  }
}

class CardSet {
  List<IndexCard> cards = [
    IndexCard(fronttext: "hello", backtext: "hallo"),
    IndexCard(fronttext: "world", backtext: "Welt"),
    IndexCard(fronttext: "variable", backtext: "Variable"),
    IndexCard(fronttext: "button", backtext: "Knopf"),
    IndexCard(fronttext: "data structure", backtext: "Datenstruktur"),
    IndexCard(fronttext: "tool", backtext: "Werkzeug"),
  ];
  String name;

  CardSet({required this.name});

  void addCard(IndexCard card) {
    cards.add(card);
  }

  void removeCard(IndexCard card) {
    cards.remove(card);
  }

  Iterator<IndexCard> getIterator() {
    return cards.iterator;
  }

  /*factory CardSet.fromMap(Map<String, dynamic> json) =>
      IndexCard(fronttext: json["front"], backtext: json["back"]);

  Map<String, dynamic> toMap() {
    return {"front": fronttext, "back": backtext};
  }*/

  @override
  String toString() {
    String result = "";
    for (var card in cards) {
      result += card.toString() + "\n";
    }
    return result;
  }
}

class Datamodel {
  Datamodel._privateConstructor();
  static final Datamodel instance = Datamodel._privateConstructor();
  List<CardSet> sets = [
    CardSet(name: "Englisch"),
    CardSet(name: "Französisch"),
    CardSet(name: "Niederländisch")
  ];

  CardSet addSet(CardSet set) {
    sets.add(set);
    return set;
  }

  void removeSet(CardSet set) {
    sets.remove(set);
  }
}

/*class Datamodel {
  Datamodel._privateConstructor();
  static final Datamodel instance = Datamodel._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    return openDatabase(join(await getDatabasesPath(), "cardsets.db"),
        onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE indexcards(front TEXT, back TEXT)",
      );
    }, version: 1);
  }

  Future<List<IndexCard>> getCards() async {
    Database db = await instance.database;
    var cards = await db.query("indexcards");
    List<IndexCard> cardList =
        cards.isNotEmpty ? cards.map((e) => IndexCard.fromMap(e)).toList() : [];
    return cardList;
  }

  Future<int> add(IndexCard card) async {
    Database db = await instance.database;
    return await db.insert("indexcards", card.toMap());
  }
}*/
