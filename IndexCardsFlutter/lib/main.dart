import 'package:flutter/material.dart';
import 'datamodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IndexCards',
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(77, 110, 255, 1.0),
        scaffoldBackgroundColor: const Color.fromRGBO(221, 221, 221, 1.0),
        textTheme: const TextTheme(bodyText1: TextStyle(fontSize: 17)),
      ),
      home: const SafeArea(
        child: HomeList(),
      ),
    );
  }
}

class HomeList extends StatefulWidget {
  const HomeList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeListState();
  }
}

class _HomeListState extends State<HomeList> {
  final List<CardSet> cardContent = Datamodel.instance.sets;
  List<CardSet>? cardContentFiltered;
  bool _showSearchBar = false;

  void onSearchBarChanged(bool value) {
    setState(() {
      _showSearchBar = value;
      if (!_showSearchBar) {
        cardContentFiltered = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text("IndexCards"),
          actions: <Widget>[
            _showSearchBar
                ? Center(
                    child: Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: TextField(
                          autofocus: true,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          style: const TextStyle(color: Colors.black),
                          onChanged: (String value) {
                            setState(() {
                              cardContentFiltered = cardContent.where((element) => element.name.toLowerCase().contains(value.toLowerCase())).toList();
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            labelText: 'Suche',
                            labelStyle: const TextStyle(color: Colors.black),
                            isDense: true,
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: const EdgeInsets.all(10),
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            onSearchBarChanged(!_showSearchBar);
                          },
                          icon: const Icon(Icons.cancel))
                    ],
                  ))
                : IconButton(
                    onPressed: () {
                      onSearchBarChanged(!_showSearchBar);
                    },
                    icon: const Icon(Icons.search_outlined))
          ],
          centerTitle: _showSearchBar ? false : true),
      body: ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: cardContentFiltered?.length ?? cardContent.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
                child: ListItemDefault(content: Text(cardContentFiltered?[index].name ?? cardContent[index].name)),
                onTap: () {
                  CardSet currentSet = cardContentFiltered?[index] ?? cardContent[index];
                  if (currentSet.cards.isNotEmpty) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LearnSetPage(
                                  set: cardContentFiltered?[index] ?? cardContent[index],
                                )));
                  }
                },
                onLongPress: () {
                  CardSet currentSet = cardContentFiltered?[index] ?? cardContent[index];
                  editDeleteDialog(currentSet).then((value) => {
                        if (value != null)
                          {
                            if (value)
                              {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateSetPage(set: currentSet),
                                    ))
                              }
                            else
                              {
                                setState(() {
                                  Datamodel.instance.removeSet(currentSet);
                                })
                              }
                          }
                      });
                });
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          createSetDialog().then((value) => {
                if (value != null)
                  {
                    setState(() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateSetPage(
                                    set: Datamodel.instance.addSet(CardSet(name: value)),
                                  )));
                    })
                  }
              });
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<bool?> editDeleteDialog(CardSet selectedSet) async {
    Future<bool?> result = showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text("Was möchtest du mit ${selectedSet.name} machen?"),
            children: [
              SimpleDialogOption(
                child: const Text("Editieren"),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
              SimpleDialogOption(
                child: const Text("Löschen"),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              SimpleDialogOption(
                child: const Text("Abbrechen"),
                onPressed: () {
                  Navigator.pop(context, null);
                },
              ),
            ],
          );
        });
    return result;
  }

  Future<String?> createSetDialog() async {
    String valueText = "";
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    Future<String?> response = showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 8,
            title: const Center(child: Text("Neues Set erstellen")),
            content: Form(
              key: _formKey,
              child: TextFormField(
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    return null;
                  } else {
                    return "Titel kann nicht leer sein";
                  }
                },
                autofocus: true,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                decoration: const InputDecoration(border: UnderlineInputBorder(), labelText: 'Titel', contentPadding: EdgeInsets.all(10)),
                onChanged: (value) {
                  valueText = value;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, null);
                },
                child: const Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () {
                  if (valueText.isNotEmpty) {
                    Navigator.pop(context, valueText);
                  } else {
                    _formKey.currentState?.validate();
                  }
                },
                child: const Text('Erstellen'),
              ),
            ],
            actionsAlignment: MainAxisAlignment.spaceBetween,
          );
        });
    return response;
  }
}

class CreateSetPage extends StatefulWidget {
  final CardSet set;

  const CreateSetPage({Key? key, required this.set}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _CreateSetPageState();
  }
}

class _CreateSetPageState extends State<CreateSetPage> {
  late FocusNode fn;

  @override
  void initState() {
    super.initState();
    fn = FocusNode();
  }

  @override
  void dispose() {
    fn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.set.name),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: widget.set.cards.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            child: ListItemDefault(
                content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(widget.set.cards[index].fronttext), const Divider(), Text(widget.set.cards[index].backtext)],
            )),
            onTap: () async {
              IndexCard card = widget.set.cards[index];
              await createIndexCardDialog(card, fn);
              setState(() {});
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          IndexCard? newCard;
          await createIndexCardDialog(null, fn).then((value) async => {newCard = value});
          if (newCard != null) {
            widget.set.cards.add(newCard!);
            setState(() {});
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<IndexCard?> createIndexCardDialog(IndexCard? card, FocusNode focusNode) async {
    String fronttext = "";
    String backtext = "";
    Future<IndexCard?> response = showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                      child: Text(
                    card != null ? "Karte editieren" : "Neue Karte erstellen",
                    style: Theme.of(context).textTheme.titleLarge,
                  )),
                  const SizedBox(height: 24.0),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: getTextField(card?.fronttext ?? "", "Vorderseite", null, (p0) => {fronttext = p0}, (p0) {
                        focusNode.requestFocus();
                      })),
                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: getTextField(
                        card?.backtext ?? "", "Rückseite", focusNode, (p0) => {backtext = p0}, (p0) => {returnCard(fronttext, backtext, card)}),
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, null);
                        },
                        child: const Text('Abbrechen'),
                      ),
                      TextButton(
                        onPressed: () {
                          returnCard(fronttext, backtext, card);
                        },
                        child: Text(card != null ? 'Ändern' : 'Erstellen'),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  )
                ],
              ),
            ),
          );
        });
    return response;
  }

  Widget getTextField(String initialValue, String labelText, FocusNode? focusNode, Function(String) onChanged, Function(String)? onSubmitted) {
    return TextFormField(
      autofocus: true,
      initialValue: initialValue,
      textAlign: TextAlign.center,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        border: const UnderlineInputBorder(),
        labelText: labelText,
        contentPadding: const EdgeInsets.all(10),
      ),
      focusNode: focusNode,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
    );
  }

  void returnCard(String fronttext, String backtext, IndexCard? card) {
    if (fronttext.isNotEmpty && backtext.isNotEmpty) {
      if (card != null) {
        card.fronttext = fronttext;
        card.backtext = backtext;
      }
      card ??= IndexCard(fronttext: fronttext, backtext: backtext);
      Navigator.pop(context, card);
    }
  }
}

class LearnSetPage extends StatefulWidget {
  final CardSet set;

  const LearnSetPage({Key? key, required this.set}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LearnSetPageState();
  }
}

class _LearnSetPageState extends State<LearnSetPage> {
  bool showBack = false;
  int index = 0;
  late IndexCard current;

  @override
  void initState() {
    super.initState();
    current = widget.set.cards[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.set.name),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: GestureDetector(
        onTap: () {
          if (!showBack) {
            setState(() {
              showBack = true;
            });
          } else {
            bool hasNext = index + 1 < widget.set.cards.length;
            if (hasNext) {
              setState(() {
                showBack = false;
                index++;
                current = widget.set.cards[index];
              });
            } else {
              showAlertDialog(context);
            }
          }
        },
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    "Karte ${index + 1}/${widget.set.cards.length}",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                LearnableCard(key: UniqueKey(), text: current.fronttext),
                const Divider(),
                LearnableCard(
                  key: UniqueKey(),
                  text: current.backtext,
                  isVisible: showBack,
                ),
              ],
            )),
      ),
    );
  }
}

showAlertDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text("Geschafft!"),
        content: const Text("Du hast alle Karten dieses Sets durchgelernt."),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class LearnableCard extends StatelessWidget {
  final String text;
  final bool isVisible;

  const LearnableCard({Key? key, required this.text, this.isVisible = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Visibility(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              color: Colors.white),
          child: Align(
            alignment: Alignment.center,
            child: Text(text),
          ),
        ),
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        visible: isVisible,
      ),
    );
  }
}

class ListItemDefault extends StatelessWidget {
  final Widget content;

  const ListItemDefault({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0), side: BorderSide(color: Theme.of(context).primaryColor, width: 2)),
        child: ListTile(
          title: content,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        elevation: 8,
        margin: const EdgeInsets.only(bottom: 10.0));
  }
}
