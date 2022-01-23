import 'package:alphabet_scroll_view/alphabet_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lysts/components/components.dart';
import 'package:provider/provider.dart';

//FIXME: make platform specific
class AddListMenu extends StatefulWidget {
  final Lyst? lyst;
  const AddListMenu({
    this.lyst,
    Key? key,
  }) : super(key: key);

  @override
  State<AddListMenu> createState() => _AddListMenuState();
}

class _AddListMenuState extends State<AddListMenu> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _type;

  @override
  void initState() {
    _titleController = TextEditingController(text: widget.lyst?.title);
    _descriptionController = TextEditingController(text: widget.lyst?.description);
    widget.lyst != null ? _type = widget.lyst!.type : _type = "coding";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserModel currentUser = Provider.of<UserModel>(context, listen: false);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              flex: 4,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 15, right: 5),
                    child: CupertinoTextField(
                      prefix: Consumer<UserModel>(builder: (context, currentUser, child) {
                        return IconButton(
                            onPressed: () {
                              if (widget.lyst != null) {
                                widget.lyst!.title = _titleController.text;
                                widget.lyst!.description = _descriptionController.text;
                                widget.lyst!.type = _type;
                                currentUser.editLyst(widget.lyst!);
                                Navigator.maybePop(context);
                              } else {
                                if (_titleController.text.trim().isNotEmpty) {
                                  currentUser.addLyst(
                                      _titleController.text.trim(), _descriptionController.text.trim(), _type);
                                  Navigator.maybePop(context);
                                }
                              }
                            },
                            icon: const Icon(Icons.save));
                      }),
                      controller: _titleController,
                      expands: false,
                      minLines: 1,
                      maxLines: 2,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                      autofocus: true,
                      placeholder: "My fun list!",
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 15, right: 5),
                    child: CupertinoTextField(
                      controller: _descriptionController,
                      expands: false,
                      minLines: 1,
                      maxLines: 2,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      autofocus: true,
                      placeholder: "decribe your tasks",
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => showDialog(
                            context: context,
                            builder: (context) => ChangeNotifierProvider<UserModel>.value(
                                value: currentUser,
                                builder: (context, child) {
                                  UserModel currentUser = Provider.of<UserModel>(context, listen: false);
                                  List types = currentUser.avaialableLystTypes.entries.map((e) => e.key).toList();
                                  return Dialog(
                                    child: SizedBox(
                                      height: MediaQuery.of(context).size.height - 200,
                                      child: AlphabetScrollView(
                                          itemExtent: 80,
                                          list: List.generate(types.length, (index) => AlphaModel(types[index])),
                                          selectedTextStyle: const TextStyle(color: Colors.black, fontSize: 13),
                                          unselectedTextStyle: const TextStyle(color: Colors.grey, fontSize: 11),
                                          itemBuilder: (context, index, str) {
                                            return Column(
                                              children: [
                                                ListTile(
                                                  onTap: () {
                                                    setState(() {
                                                      _type = currentUser.avaialableLystTypes.entries
                                                          .map((e) => e.key)
                                                          .toList()[index];
                                                    });
                                                    Navigator.maybePop(context);
                                                  },
                                                  leading: CustomIcon(
                                                      assest: currentUser.avaialableLystTypes[types[index]]![0]),
                                                  title: Text(currentUser.avaialableLystTypes.entries
                                                      .map((e) => e.key)
                                                      .toList()[index]
                                                      .toUpperCase()),
                                                ),
                                                const Divider()
                                              ],
                                            );
                                          }),
                                    ),
                                  );
                                })),
                        child: Card(
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).cardColor,
                            radius: 35,
                            child: CustomIcon(
                              assest: currentUser.avaialableLystTypes[_type]![0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}

// ignore: unused_element
const List<IconData> _icons = [
  Icons.ac_unit,
  Icons.beach_access,
  Icons.alarm,
  Icons.signal_cellular_0_bar,
  Icons.cabin,
  Icons.dangerous,
  Icons.ac_unit,
  Icons.beach_access,
  Icons.alarm,
  Icons.facebook,
  Icons.cabin,
  Icons.dangerous
];
