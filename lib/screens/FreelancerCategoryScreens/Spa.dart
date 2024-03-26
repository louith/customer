import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/screens/FreelancerCategoryScreens/components/getVerified.dart';
import 'package:customer/screens/indivProfile/indiv_profile.dart';
import 'package:flutter/material.dart';

final db = FirebaseFirestore.instance;

class SpaWorkerCard {
  final String name;
  final String address;
  final List<String> subcategories;
  final String id;

  SpaWorkerCard(
      {required this.id,
      required this.name,
      required this.address,
      required this.subcategories});
}

class SpaFreelancers extends StatefulWidget {
  const SpaFreelancers({super.key});

  @override
  State<SpaFreelancers> createState() => _SpaFreelancers();
}

class _SpaFreelancers extends State<SpaFreelancers> {
  Future<SpaWorkerCard?> getSpaWorkerCard(String plainID) async {
    final DocumentSnapshot spa = await db
        .collection('users')
        .doc(plainID)
        .collection('categories')
        .doc('Spa')
        .get();

    if (!spa.exists) {
      return null;
    }

    final DocumentSnapshot profile =
        await db.collection('users').doc(plainID).get();

    Map<String, dynamic> profileMap = profile.data() as Map<String, dynamic>;

    //gets hair subcollection document
    Map<String, dynamic> spaMap = spa.data() as Map<String, dynamic>;

    //adds subcategories to a list
    List<String> spaSubCats = spaMap.keys.toList();

    return SpaWorkerCard(
        id: plainID.toString(),
        name: profileMap['name'],
        address: profileMap['address'],
        subcategories: spaSubCats);
  }

  Future<List<SpaWorkerCard>> getSpa() async {
    List<Future<SpaWorkerCard?>> futures = [];
    for (var plainID in (await getPlainDocIds())) {
      futures.add(getSpaWorkerCard(plainID));
    }
    List<SpaWorkerCard?> spaWorkersWithNull =
        await Future.wait<SpaWorkerCard?>(futures);
    return spaWorkersWithNull.whereType<SpaWorkerCard>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SpaWorkerCard>>(
      stream: Stream.fromFuture(getSpa()), // Convert the Future to a Stream
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text('loading');
        } else {
          List<SpaWorkerCard> spaWorkers = snapshot.data!;
          return ListView.builder(
              itemCount: spaWorkers.length,
              itemBuilder: (context, index) {
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
                          spaWorkers[index].name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SubCategoriesRow(
                            itemList: spaWorkers[index].subcategories),
                        Text(spaWorkers[index].address,
                            style: const TextStyle(fontWeight: FontWeight.w300))
                      ],
                    ),
                    shape: RoundedRectangleBorder(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => IndivWorkerProfile(
                                  userID: spaWorkers[index].id.toString(),
                                  userName: spaWorkers[index].name.toString(),
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
