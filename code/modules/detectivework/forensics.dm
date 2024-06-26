//This is the output of the stringpercent(print) proc, and means about 80% of
//the print must be there for it to be complete.  (Prints are 32 digits)
#define FINGERPRINT_COMPLETE 6
/proc/is_complete_print(print)
	return stringpercent(print) <= FINGERPRINT_COMPLETE

/atom/var/list/suit_fibers
//! todo: is this entire file deprecated and should be removed?
/atom/proc/add_fibers(mob/living/carbon/human/M)
	if(M.gloves)
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.transfer_blood) //bloodied gloves transfer blood to touched objects
			if(add_blood(G.blood_color)) //only reduces the bloodiness of our gloves if the item wasn't already bloody
				G.transfer_blood--
	else if(M.bloody_hands)
		if(add_blood(M.blood_color))
			M.bloody_hands--

	if(!suit_fibers) suit_fibers = list()
	var/fibertext
	var/item_multiplier = istype(src,/obj/item)?1.2:1
	var/suit_coverage = 0
	if(M.wear_suit)
		fibertext = "Material from \a [M.wear_suit]."
		if(prob(10*item_multiplier) && !(fibertext in suit_fibers))
			suit_fibers += fibertext
		suit_coverage = M.wear_suit.armor_protection_flags

	if(M.w_uniform && (M.w_uniform.armor_protection_flags & ~suit_coverage))
		fibertext = "Fibers from \a [M.w_uniform]."
		if(prob(15*item_multiplier) && !(fibertext in suit_fibers))
			suit_fibers += fibertext

	if(M.gloves && (M.gloves.armor_protection_flags & ~suit_coverage))
		fibertext = "Material from a pair of [M.gloves.name]."
		if(prob(20*item_multiplier) && !(fibertext in suit_fibers))
			suit_fibers += "Material from a pair of [M.gloves.name]."

/datum/data/record/forensic
	name = "forensic data"
	var/uid

/datum/data/record/forensic/New(atom/A)
	uid = "\ref [A]"
	fields["name"] = sanitize(A.name)
	fields["area"] = sanitize("[get_area(A)]")
	fields["fprints"] = "unavailable"
	fields["fibers"] = A.suit_fibers ? A.suit_fibers.Copy() : list()
	fields["time"] = world.time

/datum/data/record/forensic/proc/merge(datum/data/record/other)
	var/list/prints = fields["fprints"]
	var/list/o_prints = other.fields["fprints"]
	for(var/print in o_prints)
		if(!prints[print])
			prints[print] = o_prints[print]
		else
			prints[print] = stringmerge(prints[print], o_prints[print])
	fields["fprints"] = prints

	var/list/fibers = fields["fibers"]
	var/list/o_fibers = other.fields["fibers"]
	fibers |= o_fibers
	fields["fibers"] = fibers

	var/list/blood = other.fields["blood"]
	var/list/o_blood = other.fields["blood"]
	blood |= o_blood
	fields["blood"] = blood

	fields["area"] = other.fields["area"]
	fields["time"] = other.fields["time"]
