import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/screens/FreelancerCategoryScreens/components/getVerified.dart';
import 'package:customer/screens/indivProfile/indiv_profile.dart';
import 'package:flutter/material.dart';

final db = FirebaseFirestore.instance;

class NailsWorkerCard {
  final String name;
  final String address;
  final List<String> subcategories;
  final String id;

  NailsWorkerCard(
      {required this.id,
      required this.name,
      required this.address,
      required this.subcategories});
}

class NailsFreelancers extends StatefulWidget {
  const NailsFreelancers({super.key});

  @override
  State<NailsFreelancers> createState() => _NailsFreelancersState();
}

class _NailsFreelancersState extends State<NailsFreelancers> {
  Future<NailsWorkerCard?> getNailsWorkerCard(String plainID) async {
    final DocumentSnapshot nails = await db
        .collection('users')
        .doc(plainID)
        .collection('categories')
        .doc('Nails')
        .get();

    if (!nails.exists) {
      return null;
    }

    final DocumentSnapshot profile =
        await db.collection('users').doc(plainID).get();

    Map<String, dynamic> profileMap = profile.data() as Map<String, dynamic>;

    //gets hair subcollection document
    Map<String, dynamic> nailsMap = nails.data() as Map<String, dynamic>;

    //adds subcategories to a list
    List<String> nailSubCats = nailsMap.keys.toList();

    return NailsWorkerCard(
        id: plainID.toString(),
        name: profileMap['name'],
        address: profileMap['address'],
        subcategories: nailSubCats);
  }

  Future<List<NailsWorkerCard>> getNails() async {
    List<Future<NailsWorkerCard?>> futures = [];
    for (var plainID in (await getPlainDocIds())) {
      futures.add(getNailsWorkerCard(plainID));
    }
    List<NailsWorkerCard?> nailWorkersWithNull =
        await Future.wait<NailsWorkerCard?>(futures);
    return nailWorkersWithNull.whereType<NailsWorkerCard>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NailsWorkerCard>>(
      stream: Stream.fromFuture(getNails()), // Convert the Future to a Stream
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(
            color: kPrimaryColor,
          ));
        } else {
          List<NailsWorkerCard> nailsWorkers = snapshot.data!;
          return ListView.builder(
              itemCount: nailsWorkers.length,
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
                          nailsWorkers[index].name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SubCategoriesRow(
                            itemList: nailsWorkers[index].subcategories),
                        Text(nailsWorkers[index].address,
                            style: const TextStyle(fontWeight: FontWeight.w300))
                      ],
                    ),
                    shape: const RoundedRectangleBorder(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => IndivWorkerProfile(
                                  userID: nailsWorkers[index].id.toString(),
                                  userName: nailsWorkers[index].name.toString(),
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
