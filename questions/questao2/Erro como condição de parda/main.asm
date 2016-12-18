###############################################################
 .include "macros.asm"		#  Inclui arquivo com macros 
###############################################################
.text

.globl main

#  Procedimento main do programa que calculo o seno de um ângulo x
#	
#  historico:
#  25/06/2016       Primeira versao do procedimento
#  26/06/2016	    Segunda versao do procedimento
#  02/07/2016	    Terceira versao do procedimento
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
	l.d $f2, const2
	mul.d $f12, $f12, $f2
	l.d $f2, constPi
	mul.d $f12, $f12, $f2
	l.d $f2, const360
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
#  29/07/2016	    Terceira versao do procedimento
#  02/07/2016	    Quarta versao do procedimento
#
###############################
# Quadro SenoAngulo:	      #
#	| $s0  |   $sp + 0    #		   
###############################

SenoAngulo:
#
	#################################################################################################################
#  prologo
	addiu $sp, $sp, -4			#  ajusta a pilha para 1 elemento
	sw $s0, 0($sp)				#  guarda $s0 na pilha
#  corpo do procedimento
	li $s0, 1				#  $s0 <- negativo (oscilador de sinal)
	l.d $f6, incremento			#  $f6 <- (1)
	l.d $f18, erro				#  $f18 <- erro maximo iteracoes do metodo
	
	mov.d $f4, $f12				#  $f4 <- numerador
	mov.d $f8, $f6				#  $f8 <- denominador
	mov.d $f10, $f6				#  complemento fatorial
	mov.d $f0, $f12				#  $f0 (resultado) <- x
	
LOOP:
	mov.d $f16, $f0				#  $f16 = x_n
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
	
	# $f2 <- (x^exp)/(exp!)
	div.d $f2, $f4, $f8
	
#  verifica se deve somar ou subtrair
	beq $s0, $zero, Soma			#  desvia para Soma se controlador de sinal = 0
Subrai:	#  controlador = 1
	sub.d $f0, $f0, $f2
	j Ok
Soma:
	add.d $f0, $f0, $f2
Ok:

#  Oscila o sinal
	beq $s0, $zero, ViraNegativo		#  se sinal era 0 (positivo), vira negativo (1)
ViraPositivo:
	li $s0, 0
	j SinalOk
ViraNegativo:
	li $s0, 1
SinalOk:

	sub.d $f16, $f0, $f16			#  $f16 = x_n+1 - x_n
	abs.d $f16, $f16			#  $f16 = |x_n+1 - x_n|
	c.le.d $f16, $f18			#  se falso nova iteracao
	bc1f LOOP
	
	#  $f0 ja possui o valor de retorno
# epilogo
	#  Restauramos valores dos elementos para voltarmos ao procedimento chamador
	lw $s0, 0($sp)				#  restaura $s0
	addiu $sp, $sp, 4			#  restura a pilha
	
	jr $ra
#		
	#################################################################################################################			
.data
titulo:		.asciiz "CALCULAR SENO DO ÂNGULO X\n\n"
separador:	.asciiz "\n---------------------------------------\n"
separador2:	.asciiz "---------------------------------------\n"
angulo:		.asciiz "Digite o valor do ângulo X: "
resultado:	.asciiz "Representacao no Circulo Trigonometrico:\n  Seno do ângulo X: "
incremento:	.double 1.0
constPi:	.double 3.14159265359
const2:		.double 2.0
const360:	.double 360.0
erro:		.double 1e-9
	#################################################################################################################	
