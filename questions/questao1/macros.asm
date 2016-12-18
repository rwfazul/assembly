#  Macros e equivalências usados por todos arquivos

#####################################################
#  Diretivas .eqv
.eqv programa_OK 			0
.eqv servico_imprime_string		4
.eqv servico_imprime_inteiro		1
.eqv servico_le_inteiro			5
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
.macro imprime_inteiro(%inteiro_para_impressao)
	move $a0, %inteiro_para_impressao
	li $v0, servico_imprime_inteiro
	syscall
.end_macro
#
.macro le_inteiro()
	li $v0, servico_le_inteiro
	syscall
	#  $v0 ira conter o inteiro lido
.end_macro
#
#####################################################
