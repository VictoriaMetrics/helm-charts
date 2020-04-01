result_files = Dir.glob("rspec-junit/rspec-*")
# result_files = %w(rspec-junit/rspec-0 rspec-junit/rspec-1 rspec-junit/rspec-2 rspec-junit/rspec-3 rspec-junit/rspec-4 rspec-junit/rspec-5 rspec-junit/rspec-6)
junit.parse_files result_files
junit.show_skipped_tests = true
# junit.headers = %i(file name message)
junit.report
all_test = junit.tests.map(&:attributes)
slowest_test = sort_by { |attributes| attributes[:time].to_f }.last
message "#{slowest_test[:time]} took #{slowest_test[:time]} seconds"
puts junit.failures