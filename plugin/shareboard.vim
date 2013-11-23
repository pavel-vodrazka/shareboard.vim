if exists('g:shareboard_loaded')
  finish
endif
let g:shareboard_loaded = 1

if exists('g:shareboard_python_path')
	let s:shareboard_python_path_user = g:shareboard_python_path
endif
let s:shareboard_python_path_default = 'python'

if !(executable('python') == 1 || exists('g:shareboard_python_path'))
	echo "You need python for procesing and previewing processed (not viewing and raw editing) files of this type! \n"
				\ . "You neither have python in path nor you have g:shareboard_python_path correctly defined, "
				\ . "save the option you don't have Python at all.\n"
				\ . "(plugin shareboard.vim)"
endif

if exists('g:shareboard_command')
	let s:shareboard_command_user = g:shareboard_command
endif
let s:shareboard_command_default = 'pandoc -Ss -m -t html'

if exists('g:shareboard_path')
	let s:shareboard_path_user = g:shareboard_path
endif
let s:shareboard_path_default = 'shareboard'

let g:shareboard_python_path = get(g:, 'shareboard_python_path', s:shareboard_python_path_default)
let g:shareboard_path = get(g:, 'shareboard_path', s:shareboard_path_default)
let g:shareboard_host = get(g:, 'shareboard_host', 'localhost')
let g:shareboard_port = get(g:, 'shareboard_port', '8081')
let g:shareboard_command = get(g:, 'shareboard_command', s:shareboard_command_default)
let g:shareboard_compile_ext = get(g:, 'shareboard_compile_ext', ".html")
let g:shareboard_use_default_mapping = get(g:, 'shareboard_use_default_mapping', 1)
"let g:shareboard_debug = 1

call system(g:shareboard_python_path . ' -V')
let s:shareboard_python_path_ok = eval('v:shell_error == 0 ? 1 : 0')
if !s:shareboard_python_path_ok && exists(s:shareboard_python_path_user)
	call system(s:shareboard_python_path_default . ' -V')
	if !v:shell_error
		echo "You have incorrectly defined g:shareboard_python_path = " . g:shareboard_python_path 
					\ . ". The default (" . s:shareboard_python_path_default . ") works. "
					\ . "You need to remove or redefine the custom python path to be "
					\ . "able to process and preview this type of documents."
	else
		echo "You have incorrectly defined g:shareboard_python_path = " - g:shareboard_python_path
					\ . ". The default (" . s:shareboard_python_path_default . ") also doesn't work. "
					\ . "Check whether you have python installed and in path "
					\ . "and remove the custom command, or redefine the custom command."
	endif
elseif !s:shareboard_python_path_ok && !exists(s:shareboard_python_path_user)
	echo "The default g:shareboard_python_path doesn't work for you. You need it to process and preview "
				\ . "this type of documents. Check whether you have python "
				\ . "installed and in path, or define a custom command."
endif

call system('echo test | ' . g:shareboard_command)
let s:shareboard_command_working = eval('v:shell_error == 0 ? 1 : 0')
if !s:shareboard_command_working && exists(s:shareboard_command_user)
	call system('echo test | ' . s:shareboard_command_default)
	if !v:shell_error
		echo "You have incorrectly defined g:shareboard_command = " . g:shareboard_command 
					\ . ". The default (" . s:shareboard_command_default . ") works. "
					\ . "You need to remove or redefine the custom command to be "
					\ . "able to process and preview this type of documents."
	else
		echo "You have incorrectly defined g:shareboard_command = " - g:shareboard_command
					\ . ". The default (" . s:shareboard_command_default . ") also doesn't work. "
					\ . "Check whether you have the default executable installed and in path "
					\ . "and remove the custom command, or redefine the custom command."
	endif
elseif !s:shareboard_command_working && !exists(s:shareboard_command_user)
	echo "The default g:shareboard_command doesn't work for you. You need it to process and preview "
				\ . "this type of documents. Check whether you have the default executable "
				\ . "installed and in path, or define a custom command."
endif

call system(g:shareboard_path . ' -h')
let s:shareboard_path_ok = eval('v:shell_error == 0 ? 1 : 0')
if !s:shareboard_path_ok && exists(s:shareboard_path_user)
	call system(s:shareboard_path_default . ' -h')
	if !v:shell_error
		echo "You have incorrectly defined g:shareboard_path = " . g:shareboard_path 
					\ . ". The default (" . s:shareboard_path_default . ") works. "
					\ . "You need to remove or redefine the custom command to be "
					\ . "able to preview this type of documents."
	else
		echo "You have incorrectly defined g:shareboard_path = " - g:shareboard_path
					\ . ". The default (" . s:shareboard_path_default . ") also doesn't work. "
					\ . "Check whether you have the default shareboard script installed and in path "
					\ . "and remove the custom command, or redefine the custom command."
	endif
elseif !s:shareboard_path_ok && !exists(s:shareboard_path_user)
	echo "The default g:shareboard_path doesn't work for you. You need it to preview "
				\ . "this type of documents. Check whether you have the default shareboard script "
				\ . "installed and in path, or define a custom command."
endif


function! s:Get()
  let l:lines = getline(1, '$')
  let l:str = shellescape(substitute(join(l:lines, "\n"), "\([\n#&|()\^]\)", "^\1", "g"), 1)
  return l:str
endfunction


function! s:Exec(command, null)
  if exists('g:shareboard_debug') && g:shareboard_debug
    echo "shareboard.vim: " . a:command
  endif

  if has('win32') || has('win64')
    if exists('g:shareboard_python_path')
      silent exe printf("!start %s %s",
            \ shellescape(g:shareboard_python_path),
            \ a:command)
    else
"      silent exe "!start pythonw " . shellescape(a:command)
      exe "!start pythonw " . a:command
    endif
  else
    if a:null
      let l:suffix = "& 2>&1 /dev/null"
    else
      let l:suffix = ""
    endif
    if exists('g:shareboard_python_path')
      call system(printf("%s %s %s",
            \ shellescape(g:shareboard_python_path),
            \ a:command,
            \ l:suffix))
    else
      call system(printf("%s %s", a:command, l:suffix))
    endif
  endif
endfunction

function! s:Start()
  let l:command = printf('%s -o %s -p %s start -v',
        \ g:shareboard_path,
        \ g:shareboard_host,
        \ g:shareboard_port)
"  if exists('g:shareboard_command')
"    let l:command = l:command . printf(' -c "%s"', g:shareboard_command)
"  endif
"  let l:command = l:command . ' -v'
  call s:Exec(l:command, 1)

  augroup Preview
    autocmd!
    autocmd BufWritePost <buffer> call <SID>Update()
  augroup END
endfunction

function! s:Update()
  let b:tmpfile = tempname()
  execute "write! " . b:tmpfile
  let l:command = printf('type "%s" | %s | pythonw "%s" -o %s -p %s set "-"',
  	\ b:tmpfile,
  	\ g:shareboard_command,
        \ g:shareboard_path,
        \ g:shareboard_host,
        \ g:shareboard_port)
"  call s:Exec(l:command, 1)
  silent exe "!" . l:command
endfunction

function! s:Preview()
  call s:Start()
  sleep 2
  call s:Update()
endfunction

function! s:Compile()
  let b:tmpfile = tempname()
  execute "write! " . b:tmpfile
  let l:command = printf('%s "%s" > "%s"',
        \ g:shareboard_command,
  	\ b:tmpfile,
        \ expand("%:r:h") . g:shareboard_compile_ext)
  let l:output = silent execute "!" . l:command
  echo l:output
  echo v:shell_error
endfunction

command! ShareboardStart call <SID>Start()
command! ShareboardUpdate call <SID>Update()
command! ShareboardPreview call <SID>Preview()
command! ShareboardCompile call <SID>Compile()

finish
