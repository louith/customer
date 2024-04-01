import 'package:customer/components/constants.dart';
import 'package:customer/screens/FreelancerCategoryScreens/components/getVerified.dart';
import 'package:customer/screens/indivProfile/indiv_profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentSnapshot, FirebaseFirestore;

final db = FirebaseFirestore.instance;

class MakeupWorkerCard {
  final String name;
  final String address;
  final List<String> subcategories;
  final String id;

  MakeupWorkerCard(
      {required this.id,
      required this.name,
      required this.address,
      required this.subcategories});
}

class MakeupFreelancers extends StatefulWidget {
  const MakeupFreelancers({super.key});

  @override
  State<MakeupFreelancers> createState() => _MakeupFreelancersState();
}

class _MakeupFreelancersState extends State<MakeupFreelancers> {
  Future<MakeupWorkerCard?> getMakeupWorkerCard(String plainID) async {
    final DocumentSnapshot makeup = await db
        .collection('users')
        .doc(plainID)
        .collection('categories')
        .doc('Makeup')
        .get();

    if (!makeup.exists) {
      return null;
    }

    final DocumentSnapshot profile =
        await db.collection('users').doc(plainID).get();

    Map<String, dynamic> profileMap = profile.data() as Map<String, dynamic>;

    //gets hair subcollection document
    Map<String, dynamic> makeupMap = makeup.data() as Map<String, dynamic>;

    //adds subcategories to a list
    List<String> makeupSubCats = makeupMap.keys.toList();

    return MakeupWorkerCard(
        id: plainID.toString(),
        name: profileMap['name'],
        address: profileMap['address'],
        subcategories: makeupSubCats);
  }

  Future<List<MakeupWorkerCard>> getMakeup() async {
    List<Future<MakeupWorkerCard?>> futures = [];
    for (var plainID in (await getPlainDocIds())) {
      futures.add(getMakeupWorkerCard(plainID));
    }
    List<MakeupWorkerCard?> makeupWorkersWithNull =
        await Future.wait<MakeupWorkerCard?>(futures);
    return makeupWorkersWithNull.whereType<MakeupWorkerCard>().toList();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MakeupWorkerCard>>(
      stream: Stream.fromFuture(getMakeup()), // Convert the Future to a Stream
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(
            color: kPrimaryColor,
          ));
        } else {
          List<MakeupWorkerCard> makeupWorkers = snapshot.data!;
          return ListView.builder(
              itemCount: makeupWorkers.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 4),
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
                          makeupWorkers[index].name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SubCategoriesRow(
                            itemList: makeupWorkers[index].subcategories),
                        Text(makeupWorkers[index].address,
                            style: const TextStyle(fontWeight: FontWeight.w300))
                      ],
                    ),
                    shape: const RoundedRectangleBorder(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => IndivWorkerProfile(
                                  userID: makeupWorkers[index].id.toString(),
                                  userName:
                                      makeupWorkers[index].name.toString(),
                                )),
                      );
                    },
                  ),
                );
              });
        }
      },
    );
  }
}

class SubCategoriesRow extends StatelessWidget {
  const SubCategoriesRow({super.key, required this.itemList});

  final List<dynamic> itemList;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          itemList.length,
          (index) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
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
