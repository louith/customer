import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/screens/FreelancerCategoryScreens/components/getVerified.dart';
import 'package:customer/screens/indivProfile/indiv_profile.dart';
import 'package:flutter/material.dart';

final db = FirebaseFirestore.instance;

class WaxWorkerCard {
  final String name;
  final String address;
  final List<String> subcategories;
  final String id;

  WaxWorkerCard(
      {required this.id,
      required this.name,
      required this.address,
      required this.subcategories});
}

class WaxWorkers extends StatefulWidget {
  const WaxWorkers({super.key});

  @override
  State<WaxWorkers> createState() => _WaxWorkersState();
}

class _WaxWorkersState extends State<WaxWorkers> {
  Future<WaxWorkerCard?> getWorkerCard(String plainID) async {
    final DocumentSnapshot wax = await db
        .collection('users')
        .doc(plainID)
        .collection('categories')
        .doc('Wax')
        .get();

    if (!wax.exists) {
      return null;
    }

    final DocumentSnapshot profile =
        await db.collection('users').doc(plainID).get();

    Map<String, dynamic> profileMap = profile.data() as Map<String, dynamic>;

    //gets hair subcollection document
    Map<String, dynamic> waxMap = wax.data() as Map<String, dynamic>;

    //adds subcategories to a list
    List<String> waxSubCats = waxMap.keys.toList();

    return WaxWorkerCard(
        id: plainID.toString(),
        name: profileMap['name'],
        address: profileMap['address'],
        subcategories: waxSubCats);
  }

  Future<List<WaxWorkerCard>> getWax() async {
    List<Future<WaxWorkerCard?>> futures = [];
    for (var plainID in (await getPlainDocIds())) {
      futures.add(getWorkerCard(plainID));
    }
    List<WaxWorkerCard?> waxWorkersWithNull =
        await Future.wait<WaxWorkerCard?>(futures);
    return waxWorkersWithNull.whereType<WaxWorkerCard>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WaxWorkerCard>>(
      stream: Stream.fromFuture(getWax()), // Convert the Future to a Stream
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(
            color: kPrimaryColor,
          ));
        } else {
          List<WaxWorkerCard> waxWorkers = snapshot.data!;
          return ListView.builder(
              itemCount: waxWorkers.length,
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
                          waxWorkers[index].name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SubCategoriesRow(
                            itemList: waxWorkers[index].subcategories),
                        Text(waxWorkers[index].address,
                            style: const TextStyle(fontWeight: FontWeight.w300))
                      ],
                    ),
                    shape: const RoundedRectangleBorder(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => IndivWorkerProfile(
                                  userID: waxWorkers[index].id.toString(),
                                  userName: waxWorkers[index].name.toString(),
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
