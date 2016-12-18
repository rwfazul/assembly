# Funcoes e strings usadas por ambos os procedimentos (userXuse e userXpc)

###############################################################
 .include "macros.asm"		#  Inclui arquivo com macros
###############################################################

# Procedimentos globais
.globl pergunta
.globl rola_dados
.globl imprime_resultado
#####################################################

.text

	#################################################################################################################
#  Este procedimento le a escolha do usuario (jogar ou passar)
#
#  Parametro:
#  $a0 <- string a ser impressa (user 1 ou user2)
#
#  Valor de retorno:
#  $v0 <- retona sim (1) ou nao (0)
#
#  historico:
#  08/05/2016       Primeira versao do procedimento
#  10/05/2016	    Segunda versao do procedimento
#  14/05/2016	    Terceira versao do procedimento
#
pergunta:
#
	#################################################################################################################

#  prologo
       #  procedimento folha. Nao precisa armazenar endereco de retorno ou argumento
       #  nao ha variaveis locais
       
#  corpo do procedimento
	#  $a0 <- contem string a ser impressa (Player 1 ou Player 2)
	li $v0, servico_imprime_string	
	syscall
	
	le_inteiro()			#  v0 contem o inteiro lido
#  epilogo
 	#  nao existe quadro para ser destruido
	jr $ra 				#  retorna ao procedimento chamador
	
#


	#################################################################################################################
#  Este procedimento rola os dados do usario randomicamente
#
#  Valor de retorno:
#  $v0 <- possui a soma do valor do dado branco + dado vermelho

#  historico:
#  08/05/2016       Primeira versao do procedimento
#  14/05/2016	    Segunda versao do procedimento
#
rola_dados:
#
	#################################################################################################################

#  prologo
       #  procedimento folha. Nao precisa armazenar endereco de retorno ou argumento
       
#  corpo do procedimento

	#  Dado branco
	gera_numero_random(max_random)   # $a0 contem o valor randomico
	
	
	bne $a0, $zero, rand_ok  	 #  se rand nao for 0 desvia para rand_ok
	li $a0, 1			 #  se rand for 0 muda-se valor para 1
rand_ok:
	move $t0, $a0 			 #  $t0 <- valor dado branco
	
	imprime_string(branco)		 # " Dado branco: "
	imprime_inteiro($t0)		 #  Imprime valor dado branco
	
	#  Dado vermelho
	gera_numero_random(max_random)	 #  $a0 contem o valor randomico
	bne $a0, $zero, rand_ok2	 #  testa se rand = 0
	li $a0, 1			
rand_ok2:
	move $t1, $a0      		 #  $t1 <- valor dado vermelho
	
	imprime_string(vermelho)	 #  " Dado vermelho: "
	imprime_inteiro($t1)		 #  Imprime valor do dado vermelho
		
	li $t3, 6			 #  $t3 = 6
	beq $t1, $t3, dobro   		 #  testa se dado vermelho = 6, se for desvia para dobro
	j retorna			 
dobro:
	li $t1, 12			 #  dado vermelho vale o dobro dos pontos, ou seja 12
retorna:
	addu $v0, $t0, $t1		 #  $v0 <- valor dado branco + valor dado vermelho	

#  epilogo
 	#  nao existe quadro para ser destruido
	jr $ra 				 #  retorna ao procedimento chamador
#
		
	#################################################################################################################
#  Este procedimento imprime o resultado da partida
#
#  Argumentos:
#  $a0 <- guarda pontos do player1
#  $a1 <- guarda pontos do player2/computador
#  $a3 <- guarda a string a ser impressa (user 2 ou computador)
#
#  historico:
#  08/05/2016       Primeira versao do procedimento
#  11/05/2016	    Segunda versao do procedimento
#  14/05/2016	    Terceira versao do procedimento
#
imprime_resultado:
#
	#################################################################################################################

#  prologo
       #  procedimento folha. Nao precisa armazenar endereco de retorno ou argumento
       #  nao ha variaveis locais
       
#  corpo do procedimento
	#   condicional composta, equivale a if(pontos_user > 21 && pontos_pc > 21) -> houve empate
	li $t0, 21			
	slt $t5, $a0, $t0     		#  $t5 = 1 se pontos_user < 21, ou seja,  $t5 = 0  se pontos_user > 21
	bne $t5, $zero, menor21 	#  se %t5 = 1 desvia para naoempatou

	slt $t5, $a1, $t0     		#  $t5 = 0 se pontos_pc > 21
	bne $t5, $zero, menor21		#  se $t5 = 0 nao desvia, ou seja, empatou 
	
	imprime_string(empate)		#  " RESULTADO: O jogo empatou. "
	
	j fim	
	
menor21:	
	#  se pontos_user = pontos_pc -> tambem significa que empatou		
	
	bne $a0, $a1, haganhador       #  se pontos dos dois forem iguais nao desvia
	imprime_string(empate)		
	
	j fim
	
haganhador:
	# como nao houve empate, testaremos quem venceu. se pontos_user1 > 21  -> user_2/computador venceu
	li $t0, 21
    	slt $t5, $t0, $a0      	       #  $t5 = 1 se 21 < pontos_user, ou seja, pontos_user > 21
	beq $t5, $zero, prox	       #  se $t5 = 0 desvia para prox, senao significa que user perdeu 

	li $v0, servico_imprime_string
	move $a0, $a3		       #  $a0 recebe string a ser impressa (Player 2 ou PC) contida em $a3
	syscall
	
	j fim
	
prox:
	#  se pontos_user2/computador > 21   -> user1 venceu
    	slt $t5, $t0, $a1     	       #  $t5 = 1 se pontos_pc > 21
	beq $t5, $zero, maisalto       #  se $t5 = 0 desvia para maisalto 
	imprime_string(user1_win)
	
	j fim
		
maisalto:
	#  ultimo caso: testa pontuacao mais alta
	slt $t5, $a0, $a1      	       #  $t5 = 1 se pontos_user < pontos_Pc, ou seja, pontos_pc > pontos_user
	beq $t5, $zero, uservenceu     #  se $t5 = 1 -> pc venceu.   se #t5 = 0 -> desvia para user_venceu
	
	li $v0, servico_imprime_string		    
	move $a0, $a3		       #  $a0 recebe string a ser impressa (Player 2 ou PC) contida em $a3
	syscall
	
	j fim
	
uservenceu:
	imprime_string(user1_win)      # " RESULTADO: Player 1 ganhou."
		
fim:
#  epilogo
 	#  nao existe quadro para ser destruido
	jr $ra				#  retorna ao procedimento chamador
#
	#################################################################################################################

# Stings disponiveis para ambos os procedimentos
	
.globl rodada
.globl divisor
.globl decidindo
.globl pc_joga
.globl pc_passou	
.globl joga_ou_passa	
.globl joga_ou_passa2
.globl branco	
.globl vermelho
.globl msg_placar
.globl pontos_user1
.globl pontos_user2
.globl pontos_pc		
.globl empate
.globl pc_win 	
.globl user1_win	
.globl user2_win

.data 
rodada:		.asciiz "\n\n\tRodada numero  "
divisor:	.asciiz "\n--------------------------------------------"
decidindo:	.asciiz "\n\n** Computador decide se vai jogar ou passar a vez:  "
pc_joga:	.asciiz " Irá jogar **\n"
pc_passou:	.asciiz " Passou a vez **\n"
joga_ou_passa:	.asciiz "\n\n  Player 1\n0 - Passar vez\n1 - Jogar\nEscolha: "
joga_ou_passa2: .asciiz "\n\n  Player 2\n0 - Passar vez\n1 - Jogar\nEscolha: "
branco: 	.asciiz "\nDado branco: "
vermelho:	.asciiz "\nDado vermelho: "
msg_placar:	.asciiz "\n\n	     Placar:"
pontos_user1:	.asciiz "\n	Soma Player 1: "
pontos_user2:   .asciiz "\n	Soma Player 2: "
pontos_pc:	.asciiz "\n	Soma computador: "
pc_win: 	.asciiz "\n\n\tRESULTADO: Computador ganhou.\n"
user1_win:	.asciiz "\n\n\tRESULTADO: Player 1 ganhou.\n"
user2_win:	.asciiz "\n\n\tRESULTADO: Player 2 ganhou.\n"
empate: 	.asciiz "\n\n\tRESULTADO: O jogo empatou.\n"
#
	#################################################################################################################
