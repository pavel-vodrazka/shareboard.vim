if exists('g:shareboard_loaded')
  finish
endif
let g:shareboard_loaded = 1

let g:shareboard_use_default_mapping = get(g:, 'shareboard_use_default_mapping', 1)

function! s:Init()
	if exists('g:shareboard_python_path')
		let b:shareboard_python_path_user = g:shareboard_python_path
	endif
	let b:shareboard_python_path_default = 'pythonw'

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

	call system(shellescape(g:shareboard_python_path) . ' -V')
	let b:shareboard_python_path_ok = eval('v:shell_error == 0 ? 1 : 0')
	if !b:shareboard_python_path_ok && exists(b:shareboard_python_path_user)
		call system(shellescape(b:shareboard_python_path_default) . ' -V')
		if !v:shell_error
			echo "You have incorrectly defined g:shareboard_python_path = " . g:shareboard_python_path 
						\ . ". The default (" . b:shareboard_python_path_default . ") works. "
						\ . "You need to remove or redefine the custom python path to be "
						\ . "able to process and preview this type of documents."
						\ . "\n(shareboard.vim plugin)"
		else
			echo "You have incorrectly defined g:shareboard_python_path = " - g:shareboard_python_path
						\ . ". The default (" . b:shareboard_python_path_default . ") also doesn't work. "
						\ . "Check whether you have python installed and in path "
						\ . "and remove the custom command, or redefine the custom command."
						\ . "\n(shareboard.vim plugin)"
		endif
	elseif !b:shareboard_python_path_ok && !exists(b:shareboard_python_path_user)
		echo "The default g:shareboard_python_path doesn't work for you. You need it to process and preview "
					\ . "this type of documents. Check whether you have python "
					\ . "installed and in path, or define a custom command."
					\ . "\n(shareboard.vim plugin)"
	endif

	call system('echo test | ' . g:shareboard_command)
	let b:shareboard_command_working = eval('v:shell_error == 0 ? 1 : 0')
	if !b:shareboard_command_working && exists(b:shareboard_command_user)
		call system('echo test | ' . b:shareboard_command_default)
		if !v:shell_error
			echo "You have incorrectly defined g:shareboard_command = " . g:shareboard_command 
						\ . ". The default (" . b:shareboard_command_default . ") works. "
						\ . "You need to remove or redefine the custom command to be "
						\ . "able to process and preview this type of documents."
						\ . "\n(shareboard.vim plugin)"
		else
			echo "You have incorrectly defined g:shareboard_command = " - g:shareboard_command
						\ . ". The default (" . b:shareboard_command_default . ") also doesn't work. "
						\ . "Check whether you have the default executable installed and in path "
						\ . "and remove the custom command, or redefine the custom command."
						\ . "\n(shareboard.vim plugin)"
		endif
	elseif !b:shareboard_command_working && !exists(b:shareboard_command_user)
		echo "The default g:shareboard_command doesn't work for you. You need it to process and preview "
					\ . "this type of documents. Check whether you have the default executable "
					\ . "installed and in path, or define a custom command."
					\ . "\n(shareboard.vim plugin)"
	endif

	if b:shareboard_python_path_ok
		call system(printf('%s %s -h', shellescape(g:shareboard_python_path), shellescape(g:shareboard_path)))
		let b:shareboard_path_ok = eval('v:shell_error == 0 ? 1 : 0')
		if !b:shareboard_path_ok && exists(b:shareboard_path_user)
			call system(shellescape(g:shareboard_python_path) . shellescape(b:shareboard_path_default) . ' -h')
			if !v:shell_error
				echo "You have incorrectly defined g:shareboard_path = " . g:shareboard_path 
							\ . ". The default (" . b:shareboard_path_default . ") works. "
							\ . "You need to remove or redefine the custom command to be "
							\ . "able to preview this type of documents."
							\ . "\n(shareboard.vim plugin)"
			else
				echo "You have incorrectly defined g:shareboard_path = " - g:shareboard_path
							\ . ". The default (" . b:shareboard_path_default . ") also doesn't work. "
							\ . "Check whether you have the default shareboard script installed and in path "
							\ . "and remove the custom command, or redefine the custom command."
							\ . "\n(shareboard.vim plugin)"
			endif
		elseif !b:shareboard_path_ok && !exists(b:shareboard_path_user)
			echo "The default g:shareboard_path doesn't work for you. You need it to preview "
						\ . "this type of documents. Check whether you have the default shareboard script "
						\ . "installed and in path, or define a custom command."
						\ . "\n(shareboard.vim plugin)"
		endif
	endif
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
endfunction

function! s:Start()
  call s:Init()
  let l:command = printf('%s %s -o %s -p %s start -v',
	\ shellescape(g:shareboard_python_path), 
        \ shellescape(g:shareboard_path),
        \ shellescape(g:shareboard_host),
        \ g:shareboard_port)
  call s:Exec(l:command, 0, 1)

  augroup Preview
    autocmd!
    autocmd BufWritePost <buffer> call <SID>Update()
  augroup END
endfunction

function! s:Update()
  let l:command = printf('%s | %s %s -o %s -p %s set -',
  	\ g:shareboard_command,
  	\ shellescape(g:shareboard_python_path),
        \ shellescape(g:shareboard_path),
        \ shellescape(g:shareboard_host),
        \ g:shareboard_port)
  call s:Exec(l:command, 1, 1)
endfunction

function! s:Preview()
  call s:Start()
  sleep 1
  call s:Update()
endfunction

function! s:Compile()
  call s:Init()
  let l:command = printf('%s -o %s',
			  \ g:shareboard_command,
			  \ shellescape(expand("%:r:h") . g:shareboard_compile_ext))
  call s:Exec(l:command, 1, 1)
endfunction

command! ShareboardInit call <SID>Init()
command! ShareboardStart call <SID>Start()
command! ShareboardUpdate call <SID>Update()
command! ShareboardPreview call <SID>Preview()
command! ShareboardCompile call <SID>Compile()

finish
