import 'package:customer/screens/FreelancerCategoryScreens/components/getVerified.dart';
import 'package:customer/screens/indivProfile/indiv_profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;

class LashesWorkerCard {
  final String name;
  final String address;
  final List<String> subcategories;
  final String id;

  LashesWorkerCard(
      {required this.id,
      required this.name,
      required this.address,
      required this.subcategories});
}

class LashesFreelancers extends StatefulWidget {
  const LashesFreelancers({super.key});

  @override
  State<LashesFreelancers> createState() => _LashesFreelancersState();
}

class _LashesFreelancersState extends State<LashesFreelancers> {
  Future<LashesWorkerCard?> getLashesWorkerCard(String plainID) async {
    final DocumentSnapshot lashes = await db
        .collection('users')
        .doc(plainID)
        .collection('categories')
        .doc('Lashes')
        .get();

    if (!lashes.exists) {
      return null;
    }

    final DocumentSnapshot profile =
        await db.collection('users').doc(plainID).get();

    Map<String, dynamic> profileMap = profile.data() as Map<String, dynamic>;

    //gets hair subcollection document
    Map<String, dynamic> lashesMap = lashes.data() as Map<String, dynamic>;

    //adds subcategories to a list
    List<String> lashesSubCats = lashesMap.keys.toList();

    return LashesWorkerCard(
        id: plainID.toString(),
        name: profileMap['name'],
        address: profileMap['address'],
        subcategories: lashesSubCats);
  }

  Future<List<LashesWorkerCard>> getLashes() async {
    List<Future<LashesWorkerCard?>> futures = [];
    for (var plainID in (await getPlainDocIds())) {
      futures.add(getLashesWorkerCard(plainID));
    }
    List<LashesWorkerCard?> lashesWorkersWithNull =
        await Future.wait<LashesWorkerCard?>(futures);
    return lashesWorkersWithNull.whereType<LashesWorkerCard>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LashesWorkerCard>>(
      stream: Stream.fromFuture(getLashes()), // Convert the Future to a Stream
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text('loading');
        } else {
          List<LashesWorkerCard> lashWorkers = snapshot.data!;
          return ListView.builder(
              itemCount: lashWorkers.length,
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
                          lashWorkers[index].name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SubCategoriesRow(
                            itemList: lashWorkers[index].subcategories),
                        Text(lashWorkers[index].address,
                            style: const TextStyle(fontWeight: FontWeight.w300))
                      ],
                    ),
                    shape: const RoundedRectangleBorder(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => IndivWorkerProfile(
                                  userID: lashWorkers[index].id.toString(),
                                  userName: lashWorkers[index].name.toString(),
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
