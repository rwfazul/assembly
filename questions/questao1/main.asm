###############################################################
 .include "macros.asm"		#  Inclui arquivo com macros 
###############################################################
# Diretivas .eqv

.eqv NumBits		 32		
.eqv Deslocamento	 1		
.eqv MascaraBits 	 0x00000001		#  Para isolar ultimo bit
.eqv MascaraSetaMSB	 0x80000000		#  Seta bit mais significativo
.eqv ValorInicial	 0x00000000	
###############################################################

.text

.globl main
#
#  Procedimento main do programa que realiza a multiplicacao de dois numeros em binario utilizando
#  o segundo algoritimo de multiplicacao
#	
#  historico:
#  20/06/2016       Primeira versao do procedimento
#  23/06/2016	    Segunda versao do procedimento
#  24/06/2016	    Terceira versao do procedimento
#  02/07/2016       Quarta versao do procedimento
#

main:
#
	#################################################################################################################
#  prologo
						# Nao precisamos armazenar endereco de retorno ou argumentos
#  corpo do procedimento 
	imprime_string(separador)
	imprime_string(titulo)
	
	#  Lê multiplicando
	imprime_string(multiplicando)
	le_inteiro()        			#  $v0 contem o numero lido (multiplicando)
	move $t0, $v0				#  $t0 <- multiplicando 
	
	#  Lê multiplicador
	imprime_string(multiplicador)
	le_inteiro()				#  $v0 contem o numero lido (multiplicador)
	
	#  Argumentos para funcao multiplica
	move $a1, $v0				#  $a1 <- multiplicador (lido do usuario)
	move $a0, $t0				#  $a0 <- multiplicando

	jal multiplica				#  chama procedimento
					
	move $t0, $v0				#  $t0 <- LO da multiplicacao
	move $t1, $v1				#  $t1 <- HI da multiplicacao
		
	imprime_string(separador2)
	imprime_string(resultado)
	
	imprime_string(hi)
	imprime_inteiro($t1)			#  imprime parte HI da multiplicacao
	
	imprime_string(lo)		
	imprime_inteiro($t0)			#  imprime parte LO da multiplicacao

	imprime_string(separador)
#  epilogo
 	#  Nao existe quadro para ser destruido
 	
	encerra_programa(programa_OK)
#
	
	#################################################################################################################
#  Este procedimento multiplica dois numeros com o segundo algoritimo da multiplicacao
#
#  Parametro:
#  $a0 <- multiplicando
#  $a1 <- multiplicador
#
#  Valor de retorno:
#  $v0 <- parte LO do resultado da multiplicacao
#  $v1 <- parte HI do resultado da multiplicacao
#
#  hitorico:
#  20/06/2016       Primeira versao do procedimento
#  23/06/2016	    Segunda versao do procedimento
#  24/06/2016	    Terceira versao do procedimento
#  28/06/2016       Quarta versao do procedimento	
#

###############################
# Quadro multiplica:	      #
# 	| $s0  |   $sp + 8    #
# 	| $s1  |   $sp + 4    #
#	| $s2  |   $sp + 0    #		   
###############################

multiplica:
#  prologo
	addiu $sp, $sp, -12			#  ajusta a pilha para 3 elementos
	# Salvando elementos na pilha para restauramos seus valores antes de voltar ao procedimento chamador
	sw $s0, 8($sp)				#  guarda registradores $s0 - $s2
	sw $s1, 4($sp)				#
	sw $s2, 0($sp)				#
#  corpo do procedimento
	move $s0, $a0 				#  $s0 -> multiplicando
	li $s1, ValorInicial			#  $s1 -> HI produto
	move $s2, $a1				#  $s2 -> LO produto
	li $t5, NumBits				#  limite (iteraçoes do laço)
	li $t6,	ValorInicial			#  indice do laco
	li $t7, ValorInicial			#  $t7 -> bit de carry

LOOP:	
	slt $t0, $t6, $t5			#  i deve ser menor que 3
	beq $t0, $zero, EndLoop			#  desvia para EndLoop se rodada >= 32

	and $t0, $s2, MascaraBits		#  verifica ultimo bit do produto
	beq $t0, $zero, NaoSoma 		#  se 0 desvia para NaoSoma
Soma:						#  ultimo bit do produto = 1
#  verifica bit de carry (overflow)					
	nor $t0, $s1, $zero			#  $t0 <- NOT $s1
						#  (compl. a dois - 1: 2^32 - $s1 - 1)
	sltu $t0, $t0, $s0			#  (2^32 - $s1 - 1) < $s0
	beq $t0, $zero, SemOverflow		#  se (2^32 - 1 > $s1 + $s0) vai para SemOverflow

Overflow:				        #  houve overflow
	addu $s1, $s1, $s0		        #  soma, sem interrupcao, o multiplicando com a parte HI do produto	 
	and $t1, $s1, MascaraBits	        #  $t1 <- 1 se ultimo bit parte HI = 1
	
	srl $s1, $s1, Deslocamento		#  desloca HI
	ori $s1, $s1, MascaraSetaMSB		#  Seta bit mais significativo HI
		
	beq $t1, $zero, NaoUmHI			#  desvia para NaoUmHI se ultimo bit parte HI = 0 
	j UmHI					#  se = 1 vai para UmHI
	
SemOverflow:					#  nao houve overflow	
	addu $s1, $s1, $s0			#  soma, sem interrupcao, o multiplicando com a parte HI do produto
	
	andi $t0, $s1, MascaraBits		#  $t0 <- 1 se ultimo bit da parte HI = 1
	srl $s1, $s1, Deslocamento		#  desloca HI
	beq $t0, $zero, NaoUmHI			#  desvia para NaoUmHI se ultimo bit HI = 0
	j UmHI					#  desvia para UmHI se ultimo bit HI = 1
		
NaoSoma:					
	andi $t0, $s1, MascaraBits		#  $t0 <- 1 se verifica ultimo bit da parte HI = 1
	srl $s1, $s1, Deslocamento		#  desloca HI
	beq $t0, $zero, NaoUmHI			#  desvia para NaoUmHI se ultimo bit da parte HI = 0
UmHI:						#  Ultimo bit do HI = 1
	srl $s2, $s2, Deslocamento		#  Desloca LO
	ori $s2, $s2, MascaraSetaMSB		#  Seta bit mais significativo LO
	j Ok						
NaoUmHI:
	srl $s2, $s2, Deslocamento		#  desloca LO 
	
Ok:						#  passo i foi completo	
	addi $t6, $t6, 1			#  incrementa contador i ( $t6 = $t6 + 1 )
	j LOOP
	
EndLoop:					#  Multiplicacao completa
	mthi $s1				#  move parte HI do produto para reg hi
	mtlo $s2				#  move parte LO do produto para reg lo
	
	mflo $v0				#  $v0 <- lo
	mfhi $v1				#  $v1 <- hi

# epilogo
	#  Restauramos valores dos elementos para voltarmos ao procedimento chamador
	lw $s0, 8($sp)				#  restaura $s0 - $s2
	lw $s1, 4($sp)				#
	lw $s2, 0($sp)				#
	addiu $sp, $sp, 12			#  restaura a pilha
	
	jr $ra					#  retorna ao procedimento chamador
#
	#################################################################################################################	
.data
titulo:		.asciiz "SEGUNDO ALGORITIMO DA MULTIPLICAÇÃO\n\n"
separador:	.asciiz "\n---------------------------------------\n"
separador2:	.asciiz "---------------------------------------\n"
multiplicando:	.asciiz "Digite o mulltiplicando: "
multiplicador:	.asciiz "Digite o multiplicador: "
resultado:	.asciiz "Resultado:\n"
hi:		.asciiz "\nHI: "
lo:		.asciiz "\nLO: "

	#################################################################################################################	
