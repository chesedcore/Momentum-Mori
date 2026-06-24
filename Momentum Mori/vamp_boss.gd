class_name VampBoss extends EnemyBlade



func life_steal(amount: float)->void{
	hp += amount
	print("Life STEALLLL i took " + str(amount) + " spin from you  and i now have "+ str(hp) +" amount of spiin")
}
