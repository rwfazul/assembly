#  Modulo de jogo: Player vs Computador
#	Após o Player jogar, o computador ira avaliar qual a melhor jogada (rolar os dados ou passar a vez) e realiza-la
#

###############################################################
 .include "macros.asm"		#  Inclui arquivo com macros
###############################################################

.text
	#################################################################################################################
#  Este procedimento chamado pelo main é a base do jogo versao Usuario Vs Computador
#
#  Valor de retorno:
#  
#
#  historico:
#  08/05/2016       Primeira versao do procedimento
#  10/05/2016	    Segunda versao do procedimento
#  11/05/2016	    Terceira versao do procedimento
#  14/05/2016	    Quarta versao do procedimento
#

############################################
# QUADRO USERXPC:			   #
# 	|   $a0     |        $sp + 60      #
# 	|   $a1     |        $sp + 56	   #
#	|   $a2     |        $sp + 52      #	
# 	|   $a3     |        $sp + 58      #
# 	|   $ra     |        $sp + 44	   #
# 	|   $s0     |        $sp + 40      #
# 	|   $s1     |        $sp + 35	   #
#	|   $s2     |        $sp + 32      #	
# 	|   $s3     |        $sp + 38      #
# 	|   $s4     |        $sp + 24      #
# 	|   $s5     |        $sp + 20	   #
#	|   $s6     |        $sp + 16      #	
# 	|   $s7     |        $sp + 12      #
# 	|   rodada  |        $sp + 8       #
# 	|pontos_user|        $sp + 4	   #
#	| pontos_pc |        $sp + 0       #		   
############################################

.globl userxpc	# chamada pelo main

userxpc:
#  prologo
	addi $sp, $sp, -64       	#  ajusta a pilha para 16 elementos
	# Salvando elementos na pilha para restauramos seus valores antes de voltar ao procedimento chamador
	sw $a0, 60($sp)		 	#  guarda os argumentos $a0, $a1, $a2, $a3
	sw $a1, 56($sp)	   		#
	sw $a2, 52($sp)	  		# 
	sw $a3, 48($sp)	  		#  
	sw $ra, 44($sp)	  		#  guarda endereco de retorno
	sw $s0, 40($sp)	   		#  guarda registradores $s0 - $s7
	sw $s1, 36($sp)	   		#  
	sw $s2, 32($sp)	   		#  
	sw $s3, 28($sp)	   		#  
	sw $s4, 24($sp)	   		#  
	sw $s5, 20($sp)	   		#  
	sw $s6, 16($sp)	   		# 
	sw $s7, 12($sp)	   	 	#  
	li $t0, 1  		 	#  $t0 <- 1
	sw $t0, 8($sp)	   		#  rodada = 1
	li $t1, 0  			#  $t1 <- 0
	sw $t1, 4($sp)		 	#  pontos_user = 0
	li $t2, 0	         	#  $t2 <- 0
	sw $t2, 0($sp)		 	#  pontos_pc = 0
	
#  corpo do procedimento
LOOP:
	imprime_string(divisor)		#  " ------------- "
	
	li $a2, 4 			#  rodada deve ser menor que 4
	lw $s0, 8($sp)    		#  $s0 <- rodada
	slt $t5, $s0, $a2      	 	#  $t5 = 1 se rodada < 4
	beq $t5, $zero, EXIT    	#  desvia para EXIT se rodada > 3
	
	imprime_string(rodada)		#  " Rodada numero "
	imprime_inteiro($s0)		#  Imprime numero da rodada
	
	#  Usuario deseja jogar ou  passar a vez? 
	la $a0, joga_ou_passa	   	#  argumento para o procedimento com a string correta (player1)
	jal pergunta    	        #  chama procedimento 
	move $t1, $v0              	#  $t1 <- valor de retorno do procedimento (1 = jogar, 0 = passar a vez)
	beq $t1, $zero, passa_vez	#  se $t1 = 0 desvia para passa_vez
	
	#  Jogar os dados
	jal rola_dados		 	#  chama procedimento
	lw $t1, 4($sp)          	#  $t1 <- pontos_user
	addu $t1, $t1, $v0 		#  $t1 <- $t1 + valor de retorno do procedimento (valores dos dados)
	sw $t1, 4($sp)			#  pontos_user = $t1
	
passa_vez:   # Usuario passou a vez		
	imprime_string(decidindo)	#  " ** Computador decide se vai jogar ou passar a vez: "
	
	# Testes para computador fazer jogadas mais inteligentes
	
	# Se rodada = 1, computador joga
	li $t3, 1			# $t3 <- 1
	lw $t1, 8($sp)			# $t1 <- rodada
	beq $t3, $t1, joga		# Se rodada = 1 salta para joga
	
	# Se pontos do computador > pontos do usario, computador passa
	lw $t1, 4($sp)		        # $t1 <- pontos_user 
	lw $t2, 0($sp) 		        # $t2 <- pontos_pc
	slt $t4, $t2, $t1               # $t4 = 1 se pontos_pc < pontos_user
	beq $t4, $zero, passa           # desvia para passa se  pontos_pc > pontos_user   
	
	# Se usario passou de 21, computador passa
	li $t3, 21		  
	slt $t4, $t3, $t1        	#  $t4 = 1 se 21 < pontos_user ou seja pontos_user > 21  
	bne $t4, $zero, passa  		#  desvia para passa se usario ja tiver perdido (pontos > 21)
	
joga:
	# Computador decide jogar
	imprime_string(pc_joga)		#  " Irá jogar ** "

	jal rola_dados			#  chama procedimento
	lw $t1, 0($sp) 			#  $t1 <- pontos_pc
	addu $t1, $t1, $v0		#  $t1 <- $t1 + valor de retorno do procedimento (valores dos dados)
	sw $t1, 0($sp) 			#  pontos_pc = $t1
	
	j placar	
		
passa:  #  Computador passou a vez	 
	imprime_string(pc_passou)	# "  Passou a vez ** "
	
			
	#  Imprime placar da rodada			
placar: 				
	imprime_string(msg_placar)	#  " Placar: "
	
	# Usuario 
	imprime_string(pontos_user1)	# " Soma Player 1: "
	lw $t0, 4($sp) 			#  &t0 - pontos usuario
	imprime_inteiro($t0)	  	#  Imprime pontos usuario
	
	# Computador
	imprime_string(pontos_pc)	# " Soma computador: "
	lw $t0, 0($sp)			#  $t0 <- pontos pc
	imprime_inteiro($t0)		#  Imprime pontos computador
	
	# Acrescenta rodada em 1
	lw $s0, 8($sp)    		#  $s0 <- rodada
	addiu $s0, $s0, 1      		#  $s0 <- $s0 + 1
	sw $s0, 8($sp)			#  rodada <- $s0
	j LOOP
	
#  fim das 3 rodadas
EXIT:	
	lw $a0, 4($sp)	     		#  $a0 <- ponto_user
	lw $a1, 0($sp)     	       	#  $a1 <- pontos_pc
	la $a3, pc_win			#  $a3 <- string para possivel impressao de vencedor
	jal imprime_resultado	 	#  chama procedimento

# epilogo
	#  Restauramos valores dos elementos para voltarmos ao procedimento chamador
	lw $a0, 60($sp)	   	 	#  restaura $a0, $a1, $a2, $a3
	lw $a1, 56($sp)	   		#  
	lw $a2, 52($sp)	   	 	#  
	lw $a3, 48($sp)	 		# 
	lw $ra, 44($sp)	    		#  restaura o endereco de retorno
	lw $s0, 40($sp)	   	 	#  restaura $s0 - $s7
	lw $s1, 36($sp)	   	  	#    
	lw $s2, 32($sp)	   	 	#  
	lw $s3, 28($sp)	   	       	#	 
	lw $s4, 24($sp)	   		#  
	lw $s5, 20($sp)	   		#  
	lw $s6, 16($sp)	   		# 
	lw $s7, 12($sp)	   		#  
	
	addiu $sp, $sp, 64       	#  restauramos a pilha
	jr $ra				#  retorna ao procedimento chamador
#
	#################################################################################################################
