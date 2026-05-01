import 'murmur3_get_bytes_test_suite.dart' as murmur3_get_bytes_test;
import 'murmur3a_tests_suite.dart' as murmur3a_test;
import 'murmur3f_test_suite.dart' as murmur3f_test;
import 'uint32_test_suite.dart' as uint32_test;
import 'uint64_test_suite.dart' as uint64_test;

void main() {
  uint32_test.main();
  uint64_test.main();
  murmur3_get_bytes_test.main();
  murmur3a_test.main();
  murmur3f_test.main();
}
