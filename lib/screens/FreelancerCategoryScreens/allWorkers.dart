import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/screens/FreelancerCategoryScreens/components/getVerified.dart';
import 'package:customer/screens/indivProfile/indivWorkerProfile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

final db = FirebaseFirestore.instance;

class AllWorkerCard {
  final String name;
  final String address;
  // final List<String> categories;
  final String id;
  final List<String> subcategories;

  AllWorkerCard(
      {required this.id,
      required this.name,
      required this.address,
      // required this.categories,
      required this.subcategories});

  bool containsSearchVal(String searched) {
    return subcategories
            .any((element) => element.toLowerCase().contains(searched)) ||
        name.toLowerCase().contains(searched);
  }
}

class AllWorkers extends StatefulWidget {
  const AllWorkers({super.key});

  @override
  State<AllWorkers> createState() => _AllWorkersState();
}

class _AllWorkersState extends State<AllWorkers> {
  final TextEditingController searchController = TextEditingController();
  var searchSubcat = '';
  // late Stream<List<AllWorkerCard>> _stream;

  Future<AllWorkerCard?> getAllWorkerCard(String plainID) async {
    final DocumentSnapshot profile =
        await db.collection('users').doc(plainID).get();

    Map<String, dynamic> profileMap = profile.data() as Map<String, dynamic>;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(plainID)
        .collection('categories')
        .get();

    List<String> subcats = [];
    // List<String> cats = snapshot.docs.map((doc) => doc.id).toList();

    snapshot.docs.forEach((DocumentSnapshot subcatDoc) {
      Map<String, dynamic> data = subcatDoc.data() as Map<String, dynamic>;
      subcats.addAll(data.keys);
    });
    return AllWorkerCard(
        id: plainID.toString(),
        name: profileMap['name'],
        address: profileMap['address'],
        // categories: cats,
        subcategories: subcats);
  }

  Future<List<AllWorkerCard>> getAll() async {
    List<Future<AllWorkerCard?>> futures = [];
    for (var plainID in (await getPlainDocIds())) {
      futures.add(getAllWorkerCard(plainID));
    }
    List<AllWorkerCard?> allWorkersWithNull =
        await Future.wait<AllWorkerCard?>(futures);
    return allWorkersWithNull.whereType<AllWorkerCard>().toList();
  }

  Future<List<AllWorkerCard>> searchFunc(String search) async {
    List<AllWorkerCard> allWorkers = await getAll();
    List<AllWorkerCard> matchingWorkers = [];

    // Loop through the list of AllWorkerCard objects
    for (AllWorkerCard workerCard in allWorkers) {
      // Check if any field of the AllWorkerCard object contains the searched string
      if (workerCard.containsSearchVal(search)) {
        // If the searched string is found, add it to the list of matchingWorkers
        matchingWorkers.add(workerCard);
      }
    }
    return matchingWorkers;
  }

  // _stream = Stream.fromFuture(getAll());
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: kPrimaryColor,
          title: TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchSubcat = value;
              });
              //perform ur search here
              searchFunc(value);
            },
            // onSubmitted: ,
            decoration: InputDecoration(
              hintText: 'Search',
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
              ),
              prefixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  print('icon is pressed');
                },
              ),
            ),
          )),
      body: StreamBuilder<List<AllWorkerCard>>(
          stream: Stream.fromFuture(searchFunc(searchSubcat)),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(
                color: kPrimaryColor,
              ));
            } else {
              List<AllWorkerCard> allWorkers = snapshot.data!;
              return ListView.builder(
                  itemCount: allWorkers.length,
                  itemBuilder: (context, index) {
                    var data = allWorkers[index];
                    return Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        //boxshadow code/styling
                      ),
                      child: ListTile(
                        leading: Image.asset(
                          'assets/images/suzy.jpg',
                          width: 50,
                          height: 50,
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              allWorkers[index].name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            CategoriesRow(
                                itemList: allWorkers[index].subcategories),
                            Text(allWorkers[index].address,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w300)),
                            // Text(hairWorkers[index].id.toString())
                          ],
                        ),
                        trailing: Text('4 stars'),
                        shape: RoundedRectangleBorder(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => IndivWorkerProfile(
                                      userID: allWorkers[index].id.toString(),
                                      userName:
                                          allWorkers[index].name.toString(),
                                    )),
                          );
                        },
                      ),
                    );
                  });
            }
          }),
    );
  }
}

class CategoriesRow extends StatelessWidget {
  const CategoriesRow({super.key, required this.itemList});

  final List<dynamic> itemList;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          itemList.length,
          (index) => Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
                color: Colors.purple[100],
                borderRadius: BorderRadius.circular(100)),
            child: Text(itemList[index]),
          ),
        ),
      ),
    );
  }
}
