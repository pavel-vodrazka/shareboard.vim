if exists('g:shareboard_loaded')
	finish
endif
let g:shareboard_loaded = 1

let g:shareboard_use_default_mapping = get(g:, 'shareboard_use_default_mapping', 1)

function! s:Init()
	if exists('g:shareboard_python_path')
		let b:shareboard_python_path_user = g:shareboard_python_path
	endif
	if has('win32') || has('win64')
		let b:shareboard_python_path_default = 'pythonw'
	else
		let b:shareboard_python_path_default = 'python'
	endif

	if exists('g:shareboard_command')
		let b:shareboard_command_user = g:shareboard_command
	endif
	let b:shareboard_command_default = 'pandoc -Ss -m -t html'

	if exists('g:shareboard_path')
		let b:shareboard_path_user = g:shareboard_path
	endif
	let b:shareboard_path_default = 'shareboard'

	let g:shareboard_python_path = get(g:, 'shareboard_python_path', b:shareboard_python_path_default)
	let g:shareboard_path = get(g:, 'shareboard_path', b:shareboard_path_default)
	let g:shareboard_host = get(g:, 'shareboard_host', 'localhost')
	let g:shareboard_port = get(g:, 'shareboard_port', '8081')
	let g:shareboard_command = get(g:, 'shareboard_command', b:shareboard_command_default)
	let g:shareboard_compile_ext = get(g:, 'shareboard_compile_ext', ".html")
	let g:shareboard_debug = get(g:, 'shareboard_debug', 0)

	call system(g:shareboard_python_path . ' -V')
	let b:shareboard_python_path_ok = eval('v:shell_error == 0 ? 1 : 0')
	if !b:shareboard_python_path_ok && exists('b:shareboard_python_path_user')
		call system(b:shareboard_python_path_default . ' -V')
		if !v:shell_error
			echohl WarningMsg | echomsg "You have incorrectly defined g:shareboard_python_path = " . g:shareboard_python_path 
						\ . " or it is not executable. "
						\ . "The default (" . b:shareboard_python_path_default . ") works. "
						\ . "You need to remove or redefine the custom python path to be "
						\ . "able to process and preview this type of documents. "
						\ . "(shareboard.vim plugin)" | echohl none
			return 1
		else
			echohl WarningMsg | echomsg "You have incorrectly defined g:shareboard_python_path = " - g:shareboard_python_path
						\ . " or it is not executable. "
						\ . ". The default (" . b:shareboard_python_path_default . ") also doesn't work. "
						\ . "Check whether you have python installed and in path "
						\ . "and remove the custom command, or redefine the custom command."
						\ . " (shareboard.vim plugin)" | echohl none
			return 1
		endif
	elseif !b:shareboard_python_path_ok && !exists('b:shareboard_python_path_user')
		echohl WarningMsg | echomsg "The default g:shareboard_python_path doesn't work for you. You need it to process and preview "
					\ . "this type of documents. Check whether you have python "
					\ . "installed, in path, and executable, or define a custom command. "
					\ . "(shareboard.vim plugin)" | echohl none
		return 1
	endif

	if b:shareboard_python_path_ok
		call system('echo test | ' . g:shareboard_command)
		let b:shareboard_command_working = eval('v:shell_error == 0 ? 1 : 0')
		if !b:shareboard_command_working && exists('b:shareboard_command_user')
			call system('echo test | ' . b:shareboard_command_default)
			if !v:shell_error
				echohl WarningMsg | echomsg "You have incorrectly defined g:shareboard_command = " . g:shareboard_command 
							\ . ". The default (" . b:shareboard_command_default . ") works. "
							\ . "You need to remove or redefine the custom command to be "
							\ . "able to process and preview this type of documents."
							\ . " (shareboard.vim plugin)" | echohl none
				return 1
			else
				echohl WarningMsg | echomsg "You have incorrectly defined g:shareboard_command = " . g:shareboard_command
							\ . ". The default (" . b:shareboard_command_default . ") also doesn't work. "
							\ . "Check whether you have the default executable installed and in path "
							\ . "and remove the custom command, or redefine the custom command."
							\ . " (shareboard.vim plugin)" | echohl none
				return 1
			endif
		elseif !b:shareboard_command_working && !exists('b:shareboard_command_user')
			echohl WarningMsg | echomsg "The default g:shareboard_command doesn't work for you. You need it to process and preview "
						\ . "this type of documents. Check whether you have the default executable "
						\ . "installed and in path, or define a custom command. "
						\ . "(shareboard.vim plugin)" | echohl none
			return 1
		endif
	endif

	if b:shareboard_python_path_ok && b:shareboard_command_working
		call system(printf('%s -h', g:shareboard_path))
		let b:shareboard_path_ok = eval('v:shell_error == 0 ? 1 : 0')
		if !b:shareboard_path_ok
			call system(printf('%s %s -h', g:shareboard_python_path, g:shareboard_path))
			let b:shareboard_path_ok = eval('v:shell_error == 0 ? 1 : 0')
			if b:shareboard_path_ok
				let g:shareboard_path = g:shareboard_python_path . " " . g:shareboard_path
			endif
		endif
		if !b:shareboard_path_ok && exists('b:shareboard_path_user')
			call system(b:shareboard_path_default . ' -h')
			if !v:shell_error
				echohl WarningMsg | echomsg "You have incorrectly defined g:shareboard_path = " . g:shareboard_path 
							\ . ". The default (" . b:shareboard_path_default . ") works. "
							\ . "You need to remove or redefine the custom command to be "
							\ . "able to preview this type of documents. "
							\ . "(shareboard.vim plugin)" | echohl none
				return 1
			else
				echohl WarningMsg | echomsg "You have incorrectly defined g:shareboard_path = " . g:shareboard_path
							\ . ". The default (" . b:shareboard_path_default . ") also doesn't work. "
							\ . "Check whether you have the default shareboard script installed and in path "
							\ . "and remove the custom command, or redefine the custom command. "
							\ . "(shareboard.vim plugin)" | echohl none
				return 1
			endif
		elseif !b:shareboard_path_ok && !exists('b:shareboard_path_user')
			echohl WarningMsg | echomsg "The default g:shareboard_path doesn't work for you. You need it to preview "
						\ . "this type of documents. Check whether you have the default shareboard script "
						\ . "installed and in path, or define a custom command. "
						\ . "(shareboard.vim plugin)" | echohl none
			return 1
		endif
	endif
	return 0
endfunction

function! s:Exec(command, pipe, null)
  if exists('g:shareboard_debug') && g:shareboard_debug
    echo "shareboard.vim: " . (a:pipe ? 'buffer text piped to: ' : 'external command run: ') . a:command
  endif

  if has('win32') || has('win64')
	if a:pipe
		silent execute "write !" . a:command
	else
		silent execute "!start " . a:command
	endif
  else
    if a:null
      let l:suffix = "& 2>&1 /dev/null"
    else
      let l:suffix = ""
    endif
    if a:pipe
	    silent execute "write !" . a:command
    else
	    call system(printf("%s %s", 
			    \ a:command, 
			    \ l:suffix))
    endif
  endif
  return 0
endfunction

function! s:Start()
  if s:Init()
	  return 1
  endif
  let l:command = printf('%s -o %s -p %s start -v',
        \ g:shareboard_path,
        \ g:shareboard_host,
        \ g:shareboard_port)
  call s:Exec(l:command, 0, 1)

  augroup Preview
    autocmd!
    autocmd BufWritePost <buffer> call <SID>Update()
  augroup END

  return 0
endfunction

function! s:Update()
  let l:command = printf('%s | %s -o %s -p %s set -',
  	\ g:shareboard_command,
        \ g:shareboard_path,
        \ g:shareboard_host,
        \ g:shareboard_port)
  call s:Exec(l:command, 1, 1)
  return 0
endfunction

function! s:Preview()
  if s:Start()
	  return 1
  endif
  sleep 1
  call s:Update()
  return 0
endfunction

function! s:Compile()
  if s:Init()
	  return 1
  endif
  let l:command = printf('%s -o %s',
			  \ g:shareboard_command,
			  \ shellescape(expand("%:r:h") . g:shareboard_compile_ext))
  call s:Exec(l:command, 1, 1)
  return 0
endfunction

command! ShareboardInit call <SID>Init()
command! ShareboardStart call <SID>Start()
command! ShareboardUpdate call <SID>Update()
command! ShareboardPreview call <SID>Preview()
command! ShareboardCompile call <SID>Compile()

finish
