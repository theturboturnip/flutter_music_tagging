import 'package:floor/floor.dart';

import "unified_library_db.dart";

/// Defines a simple hierarchical folder structure for Albums
/// Folders reference their parents through a foreign key, and enforce acyclicity
/// on Insert

@Entity(foreignKeys: [
  ForeignKey(
      childColumns: ['parent_tree_node_id'],
      parentColumns: ['id'],
      entity: DirTreeNode)
])
class DirTreeNode {
  @PrimaryKey(autoGenerate: true)
  final int id;

  // TODO - Validation that
  @ColumnInfo(name: "parent_tree_node_id")
  int? parentTreeNodeId;

  String name;

  DirTreeNode(this.id, this.name, this.parentTreeNodeId);
  DirTreeNode.fromNew(this.name, this.parentTreeNodeId) : this.id = 0;
}

@dao
abstract class DirDao {
  @Query("SELECT * FROM DirTreeNode WHERE parentTreeNodeId = NULL")
  Future<List<DirTreeNode>> dirChildrenOfNull();
  @Query("SELECT * FROM UnifiedAlbum "
      "WHERE parentTreeNodeId = NULL")
  Future<List<UnifiedAlbum>> albumChildrenOfNull();

  @Query("SELECT * FROM DirTreeNode WHERE parentTreeNodeId = :parentId")
  Future<List<DirTreeNode>> dirChildrenOf(int parentId);
  @Query("SELECT * FROM UnifiedAlbum "
      "WHERE parent_tree_node_id = :parentId")
  Future<List<UnifiedAlbum>> albumChildrenOf(int parentId);

  @Query("SELECT * FROM DirTreeNode WHERE id = :id")
  Future<DirTreeNode?> getById(int id);

  @transaction
  Future<bool> chainIsAcyclic(DirTreeNode notInsertedNode) async {
    var chain_ids = Set<int>();
    var currentNode = notInsertedNode;
    var parentId = currentNode.parentTreeNodeId;
    while (parentId != null) {
      if (chain_ids.contains(parentId)) {
        // Found a chain
        return false;
      }
      chain_ids.add(parentId);

      // We're in a transaction, using a foreign key, the parent must exist
      currentNode = (await getById(parentId))!;
      parentId = currentNode.parentTreeNodeId;
    }
    return true;
  }

  @insert
  Future<void> _insertTreeNodeUnchecked(DirTreeNode node);

  @transaction
  Future<bool> insertTreeNode(DirTreeNode notInsertedNode) async {
    if (await chainIsAcyclic(notInsertedNode)) {
      await _insertTreeNodeUnchecked(notInsertedNode);
      return true;
    } else {
      return false;
    }
  }
}