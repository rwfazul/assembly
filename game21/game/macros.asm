#  Macros e equivalências usados por todos arquivos

#####################################################
#  Diretivas .eqv
.eqv programa_OK 			0
.eqv servico_imprime_string		4
.eqv servico_imprime_inteiro		1
.eqv servico_le_inteiro			5
.eqv servico_encerra_programa  		17
.eqv servico_random_int			42
.eqv max_random				7	# valor topo do random (ou seja, apenas numeros < 7)
#
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
	#  $v0 ira conter inteiro lido
.end_macro
#
.macro	gera_numero_random(%valor_max_random)
	li $v0, servico_random_int
	li $a1, %valor_max_random	 #  $a1 <- valor topo do random (ou seja, apenas numeros < 7)
	syscall
	#  $a0 ira conter numero randomico
.end_macro
#
#####################################################