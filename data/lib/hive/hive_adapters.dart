import 'package:hive_ce/hive_ce.dart';

import '../entities/checklist_entity.dart';
import '../entities/checklist_item_entity.dart';

// hive_ce generates `hive_adapters.g.dart` (the TypeAdapters, as a part of this
// file) and a sibling `hive_registrar.g.dart` exposing `Hive.registerAdapters()`.
@GenerateAdapters(<AdapterSpec<Object>>[
  AdapterSpec<ChecklistEntity>(),
  AdapterSpec<ChecklistItemEntity>(),
])
part 'hive_adapters.g.dart';
