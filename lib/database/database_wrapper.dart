import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import '../constants/database.dart';
import '../types/database_entry.dart';
import '../types/rss_entry.dart';
import '../types/rss_feed.dart';

class DatabaseWrapper {
  static DatabaseWrapper _instance;

  final _feedStore = intMapStoreFactory.store(kStoreRssFeedList);

  Database _database;

  Database get database {
    if (_database == null) {
      throw Exception("Datebase not initialized");
    }
    return _database;
  }

  factory DatabaseWrapper() => _instance ??= DatabaseWrapper._internal();

  DatabaseWrapper._internal();

  Future<void> initAsync() async {
    if (_database != null) {
      return;
    }
    var databasePath = Platform.isIOS ? await getLibraryDirectory() : await getApplicationSupportDirectory();
    DatabaseFactory dbFactory = databaseFactoryIo;
    _database = await dbFactory.openDatabase("${databasePath.path}$kDatabaseName");
  }

  Future<void> setAsync(DatabaseEntry entry, Type type, [int storeId]) async {
    StoreRef store = _getStore(type, storeId);
    await store.record(entry.id).put(database, entry.toMap());
  }

  StoreRef _getStore(Type type, int storeId) {
    StoreRef store;
    if (type == RssFeed) {
      store = _feedStore;
    } else {
      store = intMapStoreFactory.store("${kStoreRssEntryList}_$storeId");
    }
    return store;
  }

  Future<void> setMultipleAsync(List<DatabaseEntry> entryList, Type type, [int storeId]) async {
    StoreRef store = _getStore(type, storeId);
    await database.transaction((transaction) async {
      await Future.forEach(entryList, (entry) async {
        await store.record(entry.id).put(transaction, entry.toMap());
      });
    });
  }

  Future<void> deleteAsync(DatabaseEntry entry, Type type, [int storeId]) async {
    StoreRef store = _getStore(type, storeId);
    await store.record(entry.id).delete(database);
  }

  Future<RssFeed> getFeedAsync(int id, [int storeId]) async {
    final feedMap = await _getAsync(_feedStore, id);
    return RssFeed.fromMap(feedMap);
  }

  Future<RssFeed> getEntryAsync(int id, [int storeId]) async {
    var store = _getStore(RssEntry, storeId);
    final entryMap = await _getAsync(store, id);
    return RssFeed.fromMap(entryMap);
  }

  Future<Map<String, dynamic>> _getAsync(StoreRef store, int id) async {
    return await store.record(id).get(database);
  }

  Future<List<RssFeed>> getAllFeedsAsync() async {
    final snapshotList = await _getAllAsync(_feedStore, kColumnName);
    return snapshotList.map((feedMap) => RssFeed.fromMap(feedMap.value)).toList();
  }

  Future<List<RssEntry>> getAllEntriesAsync(int storeId) async {
    var store = _getStore(RssEntry, storeId);
    final snapshotList = await _getAllAsync(store, kColumnDate);
    return snapshotList.map((entryMap) => RssEntry.fromMap(entryMap.value)).toList();
  }

  Future<List<RecordSnapshot<int, Map<String, dynamic>>>> _getAllAsync(StoreRef store, String sortBy) async {
    var finder = Finder(sortOrders: [SortOrder(sortBy)]);
    return await store.find(database, finder: finder);
  }
}
