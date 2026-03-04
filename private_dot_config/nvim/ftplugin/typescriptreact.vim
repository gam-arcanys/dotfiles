nnoremap <leader>fp <cmd>lua require('treesitter').go_to_parent_jsx_element()<cr>

" Switch to platform-specific file variants
nnoremap <buffer> <leader>fi :e <C-r>=expand('%:r')<CR>.ios.<C-r>=expand('%:e')<CR><CR>
nnoremap <buffer> <leader>fa :e <C-r>=expand('%:r')<CR>.android.<C-r>=expand('%:e')<CR><CR>
nnoremap <buffer> <leader>fn :e <C-r>=expand('%:r')<CR>.native.<C-r>=expand('%:e')<CR><CR>
