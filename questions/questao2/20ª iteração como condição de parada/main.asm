###############################################################
 .include "macros.asm"		#  Inclui arquivo com macros 
###############################################################
# Diretivas .eqv
.eqv iteracoes 		20	#  iteracoes das somas e subtracoes (n) do calculo do seno do angulo x
###############################################################
.text

.globl main

#  Procedimento main do programa que calculo o seno de um ângulo x
#	
#  historico:
#  25/06/2016       Primeira versao do procedimento
#  26/06/2016	    Segunda versao do procedimento
#
main:
#
	#################################################################################################################
#  prologo
						# Nao precisamos armazenar endereco de retorno ou argumentos
#  corpo do procedimento
	imprime_string(separador)
	imprime_string(titulo)
	imprime_string(angulo)
	#  Argumento para funcao SenoAngulo
	le_numeroPF()				#  $f0 contem o numero lido (multiplicando)
	
	mov.d $f12, $f0				#  $f12 <- angulo x

	#  converte -> formula: x = 2.PI.rad / 360;
	l.d $f2, dois
	mul.d $f12, $f12, $f2
	l.d $f2, pi
	mul.d $f12, $f12, $f2
	l.d $f2, maxgrau
	div.d $f12, $f12, $f2
	
	jal SenoAngulo				#  chama procedimento
	#  $f0 <- seno do angulo x
	
	imprime_string(separador2)
	imprime_string(resultado)
	
	
	imprime_numeroPF($f0)			#  imprime o seno do angulo x
	
	imprime_string(separador)
	
#  epilogo
 	#  Nao existe quadro para ser destruido
 		
	encerra_programa(programa_OK)
#
		
	#################################################################################################################
#  Este procedimento calcula o seno de um angulo x
#
#  Parametro:
#  $f0 <- angulo x
#
#  Valor de retorno:
#  $f0 <- seno do angulo x
#
#  hitorico:
#  25/06/2016       Primeira versao do procedimento
#  26/06/2016	    Segunda versao do procedimento	
#

###############################
# Quadro SenoAngulo:	      #
# 	| $s1  |   $sp + 4    #
#	| $s0  |   $sp + 0    #		   
###############################

SenoAngulo:
#
	#################################################################################################################
#  prologo
	addiu $sp, $sp, -8			#  ajusta a pilha para 2 elementos
	sw $s1, 4($sp)				#  guarda registradores $s0 - $s1
	sw $s0, 0($sp)				#
#  corpo do procedimento
	mov.d $f0, $f12				#  $f0 (resultado) <- x
	li $s1, 0				#  i =  0
	li $s0, 1				#  $s0 <- negativo (oscilador de sinal)
	mov.d $f4, $f12				#  $f4 <- numerador
	l.d $f6, incremento			#  $f6 <- (1)
	mov.d $f8, $f6				#  $f8 <- denominador
	mov.d $f10, $f6				#  complemento fatorial
	
LOOP:
	beq $s1, iteracoes, END_LOOP		#  salta para END_LOOP se i == 20
	
#  calcula (x)^expoente
	#  (x)^y ja esta calculado, apenas multiplica x * x * x, assim evita de calcular tudo novamente para encontrar (x)^y+2 
	mul.d $f4, $f4, $f12			
	mul.d $f4, $f4, $f12
#  calcula fatorial
	#  y! ja esta calculado, apenas multiplica (y+2) * (y+1) * y!, assim evita de calcular tudo novamente para encontrar (y+2)!
	add.d $f10, $f10, $f6
	mul.d $f8, $f8, $f10
	add.d $f10, $f10, $f6
	mul.d $f8, $f8, $f10
	
	# $f16 <- (x^exp)/(exp!)
	div.d $f16, $f4, $f8
	
#  verifica se deve somar ou subtrair
	beq $s0, $zero, Soma			#  desvia para Soma se controlador de sinal = 0
Subrai:	#  controlador = 1
	sub.d $f0, $f0, $f16
	j Ok
Soma:
	add.d $f0, $f0, $f16
Ok:

#  Oscila o sinal
	beq $s0, $zero, ViraNegativo		#  se sinal era 0 (positivo), vira negativo (1)
ViraPositivo:
	li $s0, 0
	j SinalOk
ViraNegativo:
	li $s0, 1
SinalOk:

	addi $s1, $s1, 1			#  i = i + 1
	j LOOP
END_LOOP:

# epilogo
	#  Restauramos valores dos elementos para voltarmos ao procedimento chamador
	lw $s1, 4($sp)				#  restura registradores $s0 - $s1
	lw $s0, 0($sp)				#
	addiu $sp, $sp, 8			#  restura a pilha
	
	jr $ra
#		
	#################################################################################################################			
.data
titulo:		.asciiz "CALCULAR SENO DO ÂNGULO X\n\n"
separador:	.asciiz "\n---------------------------------------\n"
separador2:	.asciiz "---------------------------------------\n"
angulo:		.asciiz "Digite o valor do ângulo X: "
resultado:	.asciiz "Seno do ângulo X: "
incremento:	.double 1.0
pi:		.double 3.14159265359
dois:		.double 2.0
maxgrau:	.double 360
	#################################################################################################################	
