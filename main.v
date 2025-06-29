module main

import os
import flag

fn diff(path_1 string, path_2 string, mode string, size int, pos u64) bool {
	handle_1 := os.open_file(path_1, mode) or { panic('Failed to open file ${path_1}') }
	bytes_1 := handle_1.read_bytes_at(size, pos)
	handle_2 := os.open_file(path_2, mode) or { panic('Failed to open file ${path_2}') }
	bytes_2 := handle_2.read_bytes_at(size, pos)

	return bytes_1 == bytes_2
}

fn main() {
	mut fp := flag.new_flag_parser(os.args)

	fp.application('vdiff')
	fp.version('0.0.0')
	fp.description('File differ')
	fp.skip_executable()

	thread_count := fp.int('threads', `j`, 4, 'Number of threads to use')
	chunk_size := fp.int('chunk-size', `c`, 32768, 'Chunk size to use')

	if thread_count < 0 {
		println('Number of threads must be positive')
		exit(1)
	}
	if chunk_size < 0 {
		println('Chunk size must be positive')
		exit(1)
	}

	finalized_args := fp.finalize() or {
		println(fp.usage())
		exit(1)
	}
	if finalized_args.len != 2 {
		println('Usage: vdiff <file1> <file2>')
		exit(1)
	}
	file1 := finalized_args[0]
	file2 := finalized_args[1]

	if !os.exists(file1) {
		println('no such file ${file1}')
		exit(1)
	}
	if !os.exists(file2) {
		println('no such file ${file2}')
		exit(1)
	}

	if file1 == file2 {
		println('files are identical, same path')
		exit(0)
	}

	if os.file_size(file1) != os.file_size(file2) {
		println('files differ by size, ${os.file_size(file1)} != ${os.file_size(file2)}')
		exit(0)
	}

	file_size := os.file_size(file1)

	if file_size <= chunk_size {
		if diff(file1, file2, 'rb', int(file_size), 0) {
			println('files are identical')
		} else {
			println('files differ')
		}
		exit(0)
	}

	mut threads := []thread bool{}
	for i in 0 .. file_size / u64(chunk_size) {
		threads << spawn diff(file1, file2, 'rb', chunk_size, i * u64(chunk_size))
		if i % u64(thread_count) == 0 {
			if threads.wait().any(false) {
				println('files differ')
				exit(0)
			}
			threads.clear()
		}
	}

	remainder := file_size % u64(chunk_size)
	if remainder > 0 {
		if !diff(file1, file2, 'rb', int(remainder), file_size - remainder) {
			println('files differ')
			exit(0)
		}
	}

	println('files are identical')
}
