#  Macros e equivalências usados por todos arquivos
#####################################################
#  Diretivas .eqv
.eqv programa_OK 			0
.eqv servico_imprime_string		4
.eqv servico_imprime_PF			3
.eqv servico_le_numeroPF		7
.eqv servico_encerra_programa  		17
#####################################################

#  Diretivas .macro
.macro encerra_programa(%valor_fim_programa)
	li $a0, %valor_fim_programa
	li $v0, servico_encerra_programa
	syscall
.end_macro
#
.macro imprime_string(%string_para_impressao)
	la $a0, %string_para_impressao
	li $v0, servico_imprime_string
	syscall
.end_macro
#
.macro imprime_numeroPF(%numeroPF_para_impressao)
	mov.d $f12, %numeroPF_para_impressao
	li $v0, servico_imprime_PF
	syscall
.end_macro
#
.macro le_numeroPF()
	li $v0, servico_le_numeroPF
	syscall
	#  retorna em $f0 número em ponto flutuante, precisão dupla
.end_macro
#
#####################################################
