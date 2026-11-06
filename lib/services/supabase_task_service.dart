import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTaskService {
  final SupabaseClient _client = Supabase.instance.client;

  // GET: Mengambil semua tugas
  Future<List<Map<String, dynamic>>> fetchTasks() async {
    try {
      final response = await _client
          .from('tugas')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error, stackTrace) {
      debugPrint('SERVICE FETCH ERROR: $error');
      debugPrint('FETCH STACK TRACE: $stackTrace');
      rethrow;
    }
  }

  // CREATE: Menambahkan tugas
  Future<void> addTask({
    required String title,
    required String subject,
    required String dueDate,
  }) async {
    try {
      await _client.from('tugas').insert({
        'title': title,
        'subject': subject,
        'due_date': dueDate,
      });
    } catch (error, stackTrace) {
      debugPrint('SERVICE ADD ERROR: $error');
      debugPrint('ADD STACK TRACE: $stackTrace');
      rethrow;
    }
  }

  // UPDATE: Memperbarui tugas
  Future<void> updateTask({
    required int id,
    required String title,
    required String subject,
    required String dueDate,
    required bool completed,
  }) async {
    try {
      debugPrint('UPDATE TUGAS ID: $id');

      final response = await _client
          .from('tugas')
          .update({
            'title': title,
            'subject': subject,
            'due_date': dueDate,
            'completed': completed,
          })
          .eq('id', id)
          .select();

      debugPrint('HASIL UPDATE SUPABASE: $response');

      // Jika tidak ada baris yang cocok dengan ID, tampilkan error.
      if (response.isEmpty) {
        throw Exception(
          'Tidak ada tugas dengan ID $id yang berhasil diperbarui.',
        );
      }
    } catch (error, stackTrace) {
      debugPrint('SERVICE UPDATE ERROR: $error');
      debugPrint('UPDATE STACK TRACE: $stackTrace');
      rethrow;
    }
  }

  // DELETE: Menghapus tugas
  Future<void> deleteTask(int id) async {
    try {
      final response = await _client
          .from('tugas')
          .delete()
          .eq('id', id)
          .select();

      debugPrint('HASIL DELETE SUPABASE: $response');

      if (response.isEmpty) {
        throw Exception('Tidak ada tugas dengan ID $id yang berhasil dihapus.');
      }
    } catch (error, stackTrace) {
      debugPrint('SERVICE DELETE ERROR: $error');
      debugPrint('DELETE STACK TRACE: $stackTrace');
      rethrow;
    }
  }
}
