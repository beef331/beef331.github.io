let editor = document.getElementById("jsonEditor");
let output = document.getElementById("output");
let baseJson = `
{
"Name": "ID matches in classes.json",
"ID": 0,
"Strength": 0,
"Constitution": 0,
"Dexterity": 0,
"Intelligence": 0,
"Perception": 0,
"Charisma": 0,
"Gold":0,
"MaxHP": 0,
"MaxMP": 0,
"Spells":[],
"Skills": {},
"Items": []
}`
let itemJson = 
{
	"ID" :-1,
	"Status": 3,
	"Beatitude": 0,
	"Count": 1,
	"Appearence": 0,
	"Identified": true,
	"Equipped": true,
	"Hotbar":-1
};
let parsed;
let skills = ["None", "Lockpicking", "Stealth", "Trading", "Appraisal", "Swimming", "Leadership", "Spellcasting", "Magic", "Ranged", "Sword", "Mace", "Axe", "Polearm", "Shield", "Unarmed", "Alchemy"];
let spells = {
	"NONE": 0,
	"FORCEBOLT": 1,
	"MAGICMISSILE": 2,
	"COLD ": 3,
	"FIREBALL": 4,
	"LIGHTNING": 5,
	"REMOVECURSE": 6,
	"LIGHT ": 7,
	"IDENTIFY": 8,
	"MAGICMAPPING": 9,
	"SLEEP": 10,
	"CONFUSE": 11,
	"SLOW ": 12,
	"OPENING": 13,
	"LOCKING": 14,
	"LEVITATION": 15,
	"INVISIBILITY": 16,
	"TELEPORTATION": 17,
	"HEALING": 18,
	"EXTRAHEALING": 19,
	"CUREAILMENT": 20,
	"DIG": 21,
	"SUMMON": 22,
	"STONEBLOOD": 23,
	"BLEED": 24,
	"DOMINATE": 25,
	"REFLECT_MAGIC": 26,
	"ACID_SPRAY": 27,
	"STEAL_WEAPON": 28,
	"DRAIN_SOUL": 29,
	"VAMPIRIC_AURA": 30,
	"CHARM_MONSTER": 31
}
let items = {
	"NONE": -1,
	"WOODEN_SHIELD": 0,
	"QUARTERSTAFF": 1,
	"BRONZE_SWORD": 2,
	"BRONZE_MACE": 3,
	"BRONZE_AXE": 4,
	"BRONZE_SHIELD": 5,
	"SLING": 6,
	"IRON_SPEAR": 7,
	"IRON_SWORD": 8,
	"IRON_MACE": 9,
	"IRON_AXE": 10,
	"IRON_SHIELD": 11,
	"SHORTBOW": 12,
	"STEEL_HALBERD": 13,
	"STEEL_SWORD": 14,
	"STEEL_MACE": 15,
	"STEEL_AXE": 16,
	"STEEL_SHIELD": 17,
	"STEEL_SHIELD_RESISTANCE": 18,
	"CROSSBOW": 19,
	"GLOVES": 20,
	"GLOVES_DEXTERITY": 21,
	"BRACERS": 22,
	"BRACERS_CONSTITUTION": 23,
	"GAUNTLETS": 24,
	"GAUNTLETS_STRENGTH": 25,
	"CLOAK": 26,
	"CLOAK_MAGICREFLECTION": 27,
	"CLOAK_INVISIBILITY": 28,
	"CLOAK_PROTECTION": 29,
	"LEATHER_BOOTS": 30,
	"LEATHER_BOOTS_SPEED": 31,
	"IRON_BOOTS": 32,
	"IRON_BOOTS_WATERWALKING": 33,
	"STEEL_BOOTS": 34,
	"STEEL_BOOTS_LEVITATION": 35,
	"STEEL_BOOTS_FEATHER": 36,
	"LEATHER_BREASTPIECE": 37,
	"IRON_BREASTPIECE": 38,
	"STEEL_BREASTPIECE": 39,
	"HAT_PHRYGIAN": 40,
	"HAT_HOOD": 41,
	"HAT_WIZARD": 42,
	"HAT_JESTER": 43,
	"LEATHER_HELM": 44,
	"IRON_HELM": 45,
	"STEEL_HELM": 46,
	"AMULET_SEXCHANGE": 47,
	"AMULET_LIFESAVING": 48,
	"AMULET_WATERBREATHING": 49,
	"AMULET_MAGICREFLECTION": 50,
	"AMULET_STRANGULATION": 51,
	"AMULET_POISONRESISTANCE": 52,
	"POTION_WATER": 53,
	"POTION_BOOZE": 54,
	"POTION_JUICE": 55,
	"POTION_SICKNESS": 56,
	"POTION_CONFUSION": 57,
	"POTION_EXTRAHEALING": 58,
	"POTION_HEALING": 59,
	"POTION_CUREAILMENT": 60,
	"POTION_BLINDNESS": 61,
	"POTION_RESTOREMAGIC": 62,
	"POTION_INVISIBILITY": 63,
	"POTION_LEVITATION": 64,
	"POTION_SPEED": 65,
	"POTION_ACID": 66,
	"POTION_PARALYSIS": 67,
	"SCROLL_MAIL": 68,
	"SCROLL_IDENTIFY": 69,
	"SCROLL_LIGHT": 70,
	"SCROLL_BLANK": 71,
	"SCROLL_ENCHANTWEAPON": 72,
	"SCROLL_ENCHANTARMOR": 73,
	"SCROLL_REMOVECURSE": 74,
	"SCROLL_FIRE": 75,
	"SCROLL_FOOD": 76,
	"SCROLL_MAGICMAPPING": 77,
	"SCROLL_REPAIR": 78,
	"SCROLL_DESTROYARMOR": 79,
	"SCROLL_TELEPORTATION": 80,
	"SCROLL_SUMMON": 81,
	"MAGICSTAFF_LIGHT": 82,
	"MAGICSTAFF_DIGGING": 83,
	"MAGICSTAFF_LOCKING": 84,
	"MAGICSTAFF_MAGICMISSILE": 85,
	"MAGICSTAFF_OPENING": 86,
	"MAGICSTAFF_SLOW": 87,
	"MAGICSTAFF_COLD": 88,
	"MAGICSTAFF_FIRE": 89,
	"MAGICSTAFF_LIGHTNING": 90,
	"MAGICSTAFF_SLEEP": 91,
	"RING_ADORNMENT": 92,
	"RING_SLOWDIGESTION": 93,
	"RING_PROTECTION": 94,
	"RING_WARNING": 95,
	"RING_STRENGTH": 96,
	"RING_CONSTITUTION": 97,
	"RING_INVISIBILITY": 98,
	"RING_MAGICRESISTANCE": 99,
	"RING_CONFLICT": 100,
	"RING_LEVITATION": 101,
	"RING_REGENERATION": 102,
	"RING_TELEPORTATION": 103,
	"SPELLBOOK_FORCEBOLT": 104,
	"SPELLBOOK_MAGICMISSILE": 105,
	"SPELLBOOK_COLD": 106,
	"SPELLBOOK_FIREBALL": 107,
	"SPELLBOOK_LIGHT": 108,
	"SPELLBOOK_REMOVECURSE": 109,
	"SPELLBOOK_LIGHTNING": 110,
	"SPELLBOOK_IDENTIFY": 111,
	"SPELLBOOK_MAGICMAPPING": 112,
	"SPELLBOOK_SLEEP": 113,
	"SPELLBOOK_CONFUSE": 114,
	"SPELLBOOK_SLOW": 115,
	"SPELLBOOK_OPENING": 116,
	"SPELLBOOK_LOCKING": 117,
	"SPELLBOOK_LEVITATION": 118,
	"SPELLBOOK_INVISIBILITY": 119,
	"SPELLBOOK_TELEPORTATION": 120,
	"SPELLBOOK_HEALING": 121,
	"SPELLBOOK_EXTRAHEALING": 122,
	"SPELLBOOK_CUREAILMENT": 123,
	"SPELLBOOK_DIG": 124,
	"GEM_ROCK": 125,
	"GEM_LUCK": 126,
	"GEM_GARNET": 127,
	"GEM_RUBY": 128,
	"GEM_JACINTH": 129,
	"GEM_AMBER": 130,
	"GEM_CITRINE": 131,
	"GEM_JADE": 132,
	"GEM_EMERALD": 133,
	"GEM_SAPPHIRE": 134,
	"GEM_AQUAMARINE": 135,
	"GEM_AMETHYST": 136,
	"GEM_FLUORITE": 137,
	"GEM_OPAL": 138,
	"GEM_DIAMOND": 139,
	"GEM_JETSTONE": 140,
	"GEM_OBSIDIAN": 141,
	"GEM_GLASS": 142,
	"TOOL_PICKAXE": 143,
	"TOOL_TINOPENER": 144,
	"TOOL_MIRROR": 145,
	"TOOL_LOCKPICK": 146,
	"TOOL_SKELETONKEY": 147,
	"TOOL_TORCH": 148,
	"TOOL_LANTERN": 149,
	"TOOL_BLINDFOLD": 150,
	"TOOL_TOWEL": 151,
	"TOOL_GLASSES": 152,
	"TOOL_BEARTRAP": 153,
	"FOOD_BREAD": 154,
	"FOOD_CREAMPIE": 155,
	"FOOD_CHEESE": 156,
	"FOOD_APPLE": 157,
	"FOOD_MEAT": 158,
	"FOOD_FISH": 159,
	"FOOD_TIN": 160,
	"READABLE_BOOK": 161,
	"SPELL_ITEM": 162,
	"ARTIFACT_SWORD": 163,
	"ARTIFACT_MACE": 164,
	"ARTIFACT_SPEAR": 165,
	"ARTIFACT_AXE": 166,
	"ARTIFACT_BOW": 167,
	"ARTIFACT_BREASTPIECE": 168,
	"ARTIFACT_HELM": 169,
	"ARTIFACT_BOOTS": 170,
	"ARTIFACT_CLOAK": 171,
	"ARTIFACT_GLOVES": 172,
	"CRYSTAL_BREASTPIECE": 173,
	"CRYSTAL_HELM": 174,
	"CRYSTAL_BOOTS": 175,
	"CRYSTAL_SHIELD": 176,
	"CRYSTAL_GLOVES": 177,
	"VAMPIRE_DOUBLET": 178,
	"WIZARD_DOUBLET": 179,
	"HEALER_DOUBLET": 180,
	"MIRROR_SHIELD": 181,
	"BRASS_KNUCKLES": 182,
	"IRON_KNUCKLES": 183,
	"SPIKED_GAUNTLETS": 184,
	"FOOD_TOMALLEY": 185,
	"TOOL_CRYSTALSHARD": 186,
	"CRYSTAL_SWORD": 187,
	"CRYSTAL_SPEAR": 188,
	"CRYSTAL_BATTLEAXE": 189,
	"CRYSTAL_MACE": 190,
	"BRONZE_TOMAHAWK": 191,
	"IRON_DAGGER": 192,
	"STEEL_CHAKRAM": 193,
	"CRYSTAL_SHURIKEN": 194,
	"CLOAK_BLACK": 195,
	"MAGICSTAFF_STONEBLOOD": 196,
	"MAGICSTAFF_BLEED": 197,
	"MAGICSTAFF_SUMMON": 198,
	"TOOL_BLINDFOLD_FOCUS": 199,
	"TOOL_BLINDFOLD_TELEPATHY": 200,
	"SPELLBOOK_SUMMON": 201,
	"SPELLBOOK_STONEBLOOD": 202,
	"SPELLBOOK_BLEED": 203,
	"SPELLBOOK_REFLECT_MAGIC": 204,
	"SPELLBOOK_ACID_SPRAY": 205,
	"SPELLBOOK_STEAL_WEAPON": 206,
	"SPELLBOOK_DRAIN_SOUL": 207,
	"SPELLBOOK_VAMPIRIC_AURA": 208,
	"SPELLBOOK_CHARM_MONSTER": 209,
	"POTION_EMPTY": 210,
	"ARTIFACT_ORB_BLUE": 211,
	"ARTIFACT_ORB_RED": 212,
	"ARTIFACT_ORB_PURPLE": 213,
	"ARTIFACT_ORB_GREEN": 214,
	"TUNIC": 215,
	"HAT_FEZ": 216,
	"MAGICSTAFF_CHARM": 217,
	"POTION_POLYMORPH": 218,
	"FOOD_BLOOD": 219,
	"CLOAK_BACKPACK": 220,
	"TOOL_ALEMBIC": 221,
	"POTION_FIRESTORM": 222,
	"POTION_ICESTORM": 223,
	"POTION_THUNDERSTORM": 224,
	"POTION_STRENGTH": 225,
	"SUEDE_BOOTS": 226,
	"SUEDE_GLOVES": 227,
	"CLOAK_SILVER": 228,
	"HAT_HOOD_SILVER": 229,
	"HAT_HOOD_RED": 230,
	"SILVER_DOUBLET": 231
};
let status = {
	"BROKEN": 0,
	"DECREPIT": 1,
	"WORN": 2,
	"SERVICABLE": 3,
	"EXCELLENT": 4
}

function GenerateFromJson() {
	if (parsed == undefined) {
		parsed = JSON.parse(baseJson);
	}
	while (editor.children.length > 0) {
		editor.removeChild(editor.firstChild);
	}
	for (x in parsed) {
		let inlineNode = document.createElement("div");
		inlineNode.classList.add("entry");
		let value = parsed[x];
		let key = x;
		AddKVPToNode(key, value, inlineNode);
		editor.appendChild(inlineNode);
		if (x == "Items" || x == "Spells" || x == "Skills") {
			if (key == "Items") {
				inlineNode.childNodes[0].classList.add("underline");
				for (let i = 0; i < parsed[x].length; i++) {
					for (j in parsed[x][i]) {
						inlineNode = document.createElement("div");
						inlineNode.classList.add("entry");
						inlineNode.appendChild(document.createElement("p"));
						inlineNode.childNodes[0].innerText = "\t";
						ItemProp(i, j, parsed[x][i][j], inlineNode);
						editor.appendChild(inlineNode);
					}
					editor.appendChild(document.createElement("hr"));
				}
			}
			if (key == "Skills") {
				for (i in parsed[x]) {
					if (i == "None") continue;
					AddSkill(i);
				}
				AddSkill("None");
			}
			if (key == "Spells") {
				for (i in parsed[x]) {
					if (parsed[x][i] == 0) continue;
					AddSpell(parsed[x][i]);
				}
				AddSpell("NONE");
			}
		}
	}
	RedrawJson();
}

function AddKVPToNode(key, value, node, func = null) {
	let keyNode = document.createElement("p");
	let valNode = document.createElement("input");
	keyNode.classList.add("key");
	valNode.classList.add(typeof value);
	valNode.innerText = value;
	if (typeof value == "number") {
		valNode.type = "number";
	} else if (typeof value == "boolean") {
		valNode.type = "checkbox";
	}
	keyNode.innerText = key;
	node.appendChild(keyNode);
	let semiNode = document.createElement("p")
	semiNode.innerText = " \t:\t ";
	node.appendChild(semiNode);
	if (key == "ID") {
		valNode.min = 0;
		valNode.max = 12;
	}
	if (key != "Items" && key != "Spells" && key != "Skills") {
		valNode.value = parsed[key];
		node.appendChild(valNode);
		valNode.oninput = function (event) { 
			if(typeof value == "number")  parsed[key] = Number(event.target.value); 
			else if(typeof value == "boolean")  parsed[key] = Boolean(event.target.value); 
			else	parsed[key] = event.target.value; 
			RedrawJson();
		};
	} else if(key == "Items"){
		keyNode.onclick = function (event) { AddNodeVal(event, key) };
	}
}

function ItemProp(itemIndex, key, value, node) {
	let keyNode = document.createElement("p");
	keyNode.classList.add("key");
	keyNode.innerText = key;
	node.appendChild(keyNode);
	let semiNode = document.createElement("p")
	semiNode.innerText = " \t:\t ";
	node.appendChild(semiNode);
	if (key != "ID" && key != "Status") {
		let valNode = document.createElement("input");
		valNode.classList.add(typeof value);
		valNode.value = parsed["Items"][itemIndex][key];
		node.appendChild(valNode);
		if (typeof value == "number") {
			valNode.type = "number";
		}
		if (typeof value == "boolean") {
			valNode.type = "checkbox";
			valNode.checked = value;
			valNode.oninput = function (event) {
				 parsed["Items"][itemIndex][key] = event.target.checked; 
				 RedrawJson();
				};
		} else {
			valNode.oninput = function (event) { 
				parsed["Items"][itemIndex][key] = Number(event.target.value);
				RedrawJson();
			};
		}
	} else {
		let isID = key == "ID";
		let dict = isID ? items : status;
		let selection = isID ? GetItem(value) : GetStatus(value);
		let selnode = CreateDropDown(node, selection, dict);
		selnode.oninput = function (event) {
			if (event.target.value != "NONE") {
				parsed["Items"][itemIndex][key] = dict[event.target.value]
			} else {
				if (isID) {
					delete parsed["Items"][itemIndex];
					GenerateFromJson();
				}
			}
			RedrawJson();
		};
	}
}

function RedrawJson(){
	output.innerText = CleanJson();
}

function AddNodeVal(event, jsonNode) {
	let count = parsed[jsonNode].length;
	parsed[jsonNode].push(JSON.parse(JSON.stringify(itemJson)));
	GenerateFromJson();
}

function CleanJson() {

	let cached = JSON.parse(JSON.stringify(parsed));
	if(cached["ID"] >12) cached["ID"] = 12;
	if(cached["ID"] <0) cached["ID"] = 0;


	if ("None" in cached["Skills"])
		delete cached["Skills"]["None"];
	for (i in cached["Skills"]) {
		if (cached["Skills"][i] == 0) {
			delete cached["Skills"][i];
		}
	}
	let spells = [];
	for (i in cached["Spells"]) {
		if (!(cached["Spells"][i] in spells)) {
			spells.push(cached["Spells"][i]);
		}
	}
	cached["Spells"] = spells;
	for (let i = cached["Items"].length - 1; i >= 0; i--) {
		if (cached["Items"][i] == null || cached["Items"][i]["ID"] == -1) {
			delete cached["Items"][i];
			continue;
		}

		if (cached["Items"][i]["Hotbar"] < 0 || cached["Items"][i]["Hotbar"] > 9) {
			delete cached["Items"][i]["Hotbar"];
		}
	}
	return JSON.stringify(cached, null, 4);

}

function CreateDropDown(parent, selection, collection) {
	let sel = document.createElement("select");
	collection = Array.isArray(collection) ? collection : Object.keys(collection);
	for (let i = 0; i < collection.length; i++) {
		let newNode = document.createElement("option");
		newNode.value = collection[i];
		newNode.innerText = collection[i];
		sel.appendChild(newNode);
		if (collection[i] == selection) {
			newNode.selected = "selected";
		}
	}
	parent.appendChild(sel);
	return sel
}

function AddSkill(skill) {
	let inlineNode = document.createElement("div");
	inlineNode.classList.add("entry");
	inlineNode.appendChild(document.createElement("p"));
	inlineNode.childNodes[0].innerText = "\t";
	let sel = CreateDropDown(inlineNode, skill, skills);
	sel.oninput = function (ev) {
		delete parsed["Skills"][skill];
		parsed["Skills"][ev.target.value] = 0;
		GenerateFromJson();
	};
	let newNode = document.createElement("p");
	newNode.innerText = "\t:\t";
	inlineNode.appendChild(newNode);
	if (skill != "None") {
		newNode = document.createElement("input");
		newNode.type = "number";
		newNode.classList.add("number");
		newNode.min = 0;
		newNode.max = 100;
		newNode.value = parsed["Skills"][skill];
		newNode.oninput = function (event) {
			parsed["Skills"][skill] = Number(event.target.value);
			RedrawJson();
		}
		inlineNode.appendChild(newNode);
	}
	editor.appendChild(inlineNode);
}

function AddSpell(spell) {
	let inlineNode = document.createElement("div");
	inlineNode.classList.add("entry");
	inlineNode.appendChild(document.createElement("p"));
	inlineNode.childNodes[0].innerText = "\t";
	let sel = CreateDropDown(inlineNode, GetSpell(spell), spells);
	sel.oninput = function (ev) {
		console.log(ev.target.value);
		if (ev.target.value != "NONE") {
			let index = parsed["Spells"].indexOf(spell);
			if(index >=0)parsed["Spells"][index] = spells[ev.target.value];
			else parsed["Spells"].push(spells[ev.target.value]);
		} else {
			let index = parsed["Spells"].indexOf(spell);
			if (index >=0) delete parsed["Spells"][index];
		}
		GenerateFromJson();
	};
	editor.appendChild(inlineNode);
}

function GetSpell(id) {
	let keys = Object.keys(spells);
	for (i in keys) {
		if (spells[keys[i]] == id) {
			return keys[i];
		}
	}
	return "NONE";
}

function GetItem(id) {
	let keys = Object.keys(items);
	for (i in keys) {
		if (items[keys[i]] == id) {
			return keys[i];
		}
	}
	return "NONE";
}
function GetStatus(id) {
	let keys = Object.keys(status);
	for (i in keys) {
		if (status[keys[i]] == id) {
			return keys[i];
		}
	}
	return "Broken";
}


GenerateFromJson();
document.oninput = RedrawJson();