########################################################################################################
#       O jogo consiste em uma partida de 3 rodadas onde os jogadores possuem a sua disposicao 
# dois dados: um branco e um vermelho. Ambos os jogadores comecam com 0 pontos.
#	
#	A cada jogada, cada jogador tem a opção de escolher se vai jogar o dado ou passar a vez. Se o
# jogador passar a vez, não joga os dados. Se o jogador escolher jogar os dados, joga primeiro o dado
# branco. O valor do dado branco soma-se aos pontos que ele possui (por exemplo, se o jogador
# tinha 5 pontos e tirou 3 no dado branco, agora ele tem 8 pontos).
# 	Logo em seguida, o jogador deve jogar o dado vermelho. Se o valor do 
# dado vermelho for 6, este valor é duplicado e somado aos pontos que ele já possui 
# (por exemplo, se o jogador tinha 8 pontos após jogar o dado branco, e tirou 6 no dado vermelho
# ele agora tem 8 + (2 x 6) = 20 pontos)
#	Outro valor no dado vermelho é simplesmente somado aos pontos do jogador, assim como o dado
# branco.
#
#	Uma jogada termina quando todos os jogadores fizerem sua ação (seja esta ação passar a vez ou jogar).
# Após as 3 jogadas, o resultado do jogo é o seguinte:
#	 - o jogador que passar de 21 pontos perde (se os dois passarem, o jogo empata).
#	 - se nenhum dos jogadores passar dos 21 pontos, o que mais se aproximar de 21 pontos ganha.
#
#	* O jogo possui dois modulos: Jogador Vs Jogador ou Jogador Vs Computador
#	* Ao final de cada partida o usario pode escolher jogavente
#	* O lançamento dos dados é simulado atraves de números randômicos

	#################################################################################################################
#
#  Este procedimento chama as funcao equivalente a escolha do tipo de jogo feita pelo usuario 
#
#
#  historico:
#  08/05/2016       Primeira versao do procedimento
#  11/05/2016	    Segunda versao do procedimento
#  14/05/2016	    Terceira versao do procedimento
#

###############################################################
 .include "macros.asm"		#  Inclui arquivo com macros
###############################################################


.text

.globl main

main:
#
	#################################################################################################################
#  prologo
					# Nao precisamos armazenar endereco de retorno ou argumentos
		
#  corpo do procedimento
jogar_novamente:  # Reiniciar o jogo caso necessario
	imprime_string(divisor)		#  " ------------------- "

	imprime_string(titulo)		#  " VINTE UM "
	
	imprime_string(pxp)		#  " 0 - Usuario x Usuario "
	
	imprime_string(pxc)		#  " 1 - Usuario x Computador "
	
	imprime_string(escolha)		#  " Escolha: "
		
	le_inteiro()			#  $v0 contem o inteiro lido (escolha do usuario)
 	
	beq $v0, $zero, play1xplay2	#  se $v0 = 0 salta para playxplay2 (modo de jogo Jogador Vs Jogador
	jal userxpc			#  chama procedimento ($v0 = 1)
	j fim
	
play1xplay2:
	jal userxuser			#  chama procedimento
	
fim:
	imprime_string(divisor)		
	
	#  Jogar novamente?
	imprime_string(novamente)	#  " Deseja jogar novamente? 0 - Nao 1 - Sim   Escolha: "
	
	le_inteiro()			#  $v0 contem o inteiro lido (escolha do usuario)
	  
	beq $v0, $zero, sair 		#  se $v0 = 0 (nao deseja jogar novamente) salta para sair 
	imprime_string(divisor)
	
	imprime_string(again)		#  " NOVO JOGO INICIADO "
	
	j jogar_novamente
	
sair:
	imprime_string(divisor)		#  " ------------------- "
	imprime_string(fim_de_jogo)	#  " FIM DE JOGO "
	imprime_string(divisor)		#  " ------------------- "
	
#  epilogo
 	#  Nao existe quadro para ser destruido

	encerra_programa(programa_OK)
#
	#################################################################################################################
	
.data
titulo:		.asciiz "\n\t VINTE UM\n"
pxp:		.asciiz "0 - Usuario x Usuario\n"
pxc:    	.asciiz "1 - Usuario x Computador\n"
escolha:	.asciiz "Escolha: "
novamente:	.asciiz "\n\nDeseja jogar novamente?\n0 - Nao\n1 - Sim\nEscolha: "
again:		.asciiz "\n\n\t*NOVO JOGO INICIADO*\n"
fim_de_jogo: 	.asciiz "\n\n\t*FIM DE JOGO*\n"
#
	#################################################################################################################
