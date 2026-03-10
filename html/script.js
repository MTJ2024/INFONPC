let currentNPCs = [];
let selectedNPCIndex = null;
let isEditMode = false;

// Color map for preview and list dots
const COLOR_MAP = {
    gold:  '#ffdf00',
    weiss: '#ffffff',
    rot:   '#ff3232',
    gruen: '#32ff32',
    blau:  '#6496ff'
};

// ===== NUI MESSAGE HANDLER =====
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'open') {
        openUI(data.npcs || []);
    } else if (data.action === 'close') {
        closeUI();
    } else if (data.action === 'updateNPCs') {
        currentNPCs = data.npcs || [];
        renderNPCList();
        updateNPCCount();
    } else if (data.action === 'setPosition') {
        if (data.coords) {
            document.getElementById('posX').value = data.coords.x.toFixed(4);
            document.getElementById('posY').value = data.coords.y.toFixed(4);
            document.getElementById('posZ').value = data.coords.z.toFixed(4);
        }
    } else if (data.action === 'setHeading') {
        if (data.heading !== undefined) {
            document.getElementById('heading').value = data.heading.toFixed(4);
        }
    }
});

// ESC to close
document.addEventListener('keyup', function(event) {
    if (event.key === 'Escape') {
        closeUI();
    }
});

// ===== UI OPEN/CLOSE =====
function openUI(npcs) {
    currentNPCs = npcs;
    document.getElementById('npc-manager').classList.remove('hidden');
    renderNPCList();
    updateNPCCount();
    showWelcome();
}

function closeUI() {
    document.getElementById('npc-manager').classList.add('hidden');
    fetch('https://' + GetParentResourceName() + '/closeUI', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

function updateNPCCount() {
    var el = document.getElementById('npcCount');
    if (el) el.textContent = currentNPCs.length + ' NPCs';
}

// ===== NPC LIST WITH COLOR DOTS =====
function renderNPCList() {
    var listContainer = document.getElementById('npcList');
    listContainer.innerHTML = '';
    
    currentNPCs.forEach(function(npc, index) {
        var item = document.createElement('div');
        item.className = 'npc-item' + (index === selectedNPCIndex ? ' active' : '');
        item.onclick = function() { editNPC(index); };
        
        var header = document.createElement('div');
        header.className = 'npc-item-header';
        
        // Color dot
        var dot = document.createElement('span');
        dot.className = 'color-dot ' + (npc.textColor || 'gold');
        header.appendChild(dot);
        
        var title = document.createElement('span');
        title.textContent = 'NPC #' + (index + 1);
        header.appendChild(title);
        
        var info = document.createElement('div');
        info.className = 'npc-item-info';
        var msgCount = (npc.messages && npc.messages.length) || 0;
        var font = npc.textFont || 'pricedown';
        info.textContent = (npc.pedModel || '?') + ' | ' + msgCount + ' Nachr. | ' + font;
        
        item.appendChild(header);
        item.appendChild(info);
        listContainer.appendChild(item);
    });
}

// ===== PED MODEL DROPDOWN =====
function onPedModelChange() {
    var sel = document.getElementById('pedModelSelect');
    var custom = document.getElementById('pedModelCustom');
    if (sel.value === '__custom__') {
        custom.style.display = 'block';
        custom.focus();
    } else {
        custom.style.display = 'none';
    }
}

function getPedModel() {
    var sel = document.getElementById('pedModelSelect');
    if (sel.value === '__custom__') {
        return document.getElementById('pedModelCustom').value.trim();
    }
    return sel.value;
}

function setPedModel(model) {
    var sel = document.getElementById('pedModelSelect');
    var custom = document.getElementById('pedModelCustom');
    var found = false;
    for (var i = 0; i < sel.options.length; i++) {
        if (sel.options[i].value === model) {
            sel.selectedIndex = i;
            found = true;
            break;
        }
    }
    if (!found) {
        sel.value = '__custom__';
        custom.style.display = 'block';
        custom.value = model;
    } else {
        custom.style.display = 'none';
    }
}

// ===== CREATE NEW NPC =====
function createNewNPC() {
    selectedNPCIndex = null;
    isEditMode = false;
    
    document.getElementById('editorTitle').textContent = 'Neuer NPC';
    document.getElementById('deleteBtn').style.display = 'none';
    document.getElementById('editorSection').style.display = 'block';
    document.getElementById('welcomeSection').style.display = 'none';
    
    setPedModel('a_m_y_hipster_01');
    document.getElementById('posX').value = '';
    document.getElementById('posY').value = '';
    document.getElementById('posZ').value = '';
    document.getElementById('heading').value = '0';
    document.getElementById('scenario').value = 'WORLD_HUMAN_CLIPBOARD';
    document.getElementById('enablePatrol').checked = false;
    document.getElementById('patrolRadius').value = '10.0';
    document.getElementById('textFont').value = 'pricedown';
    document.getElementById('textColor').value = 'gold';
    document.getElementById('textScale').value = '0.968';
    document.getElementById('messages').value = '';
    
    updatePreview();
    renderNPCList();
}

// ===== EDIT EXISTING NPC =====
function editNPC(index) {
    selectedNPCIndex = index;
    isEditMode = true;
    
    var npc = currentNPCs[index];
    
    document.getElementById('editorTitle').textContent = 'NPC #' + (index + 1) + ' bearbeiten';
    document.getElementById('deleteBtn').style.display = 'inline-block';
    document.getElementById('editorSection').style.display = 'block';
    document.getElementById('welcomeSection').style.display = 'none';
    
    setPedModel(npc.pedModel || 'a_m_y_hipster_01');
    document.getElementById('posX').value = npc.position ? (npc.position.x || '') : '';
    document.getElementById('posY').value = npc.position ? (npc.position.y || '') : '';
    document.getElementById('posZ').value = npc.position ? (npc.position.z || '') : '';
    document.getElementById('heading').value = npc.heading || 0;
    document.getElementById('scenario').value = npc.scenario || 'WORLD_HUMAN_CLIPBOARD';
    document.getElementById('enablePatrol').checked = npc.enablePatrol || false;
    document.getElementById('patrolRadius').value = npc.patrolRadius || 10.0;
    document.getElementById('textFont').value = npc.textFont || 'pricedown';
    document.getElementById('textColor').value = npc.textColor || 'gold';
    document.getElementById('textScale').value = npc.textScale || 0.968;
    document.getElementById('messages').value = (npc.messages || []).join('\n');
    
    updatePreview();
    renderNPCList();
}

// ===== SAVE NPC =====
function saveNPC() {
    var pedModel = getPedModel();
    var posX = parseFloat(document.getElementById('posX').value);
    var posY = parseFloat(document.getElementById('posY').value);
    var posZ = parseFloat(document.getElementById('posZ').value);
    var heading = parseFloat(document.getElementById('heading').value);
    var scenario = document.getElementById('scenario').value;
    var enablePatrol = document.getElementById('enablePatrol').checked;
    var patrolRadius = parseFloat(document.getElementById('patrolRadius').value);
    var textFont = document.getElementById('textFont').value || 'pricedown';
    var textColor = document.getElementById('textColor').value || 'gold';
    var textScale = parseFloat(document.getElementById('textScale').value) || 0.968;
    var messagesText = document.getElementById('messages').value;
    
    if (!pedModel) {
        alert('Bitte wähle ein Ped Model!');
        return;
    }
    if (isNaN(posX) || isNaN(posY) || isNaN(posZ)) {
        alert('Bitte gib gültige Koordinaten ein!\nNutze den Button "Aktuelle Position".');
        return;
    }
    
    var messages = messagesText.split('\n').filter(function(m) { return m.trim() !== ''; });
    if (messages.length === 0) {
        alert('Bitte gib mindestens eine Nachricht ein!');
        return;
    }
    
    var npcData = {
        pedModel: pedModel,
        position: { x: posX, y: posY, z: posZ },
        heading: heading || 0,
        scenario: scenario || 'WORLD_HUMAN_CLIPBOARD',
        enablePatrol: enablePatrol,
        patrolRadius: patrolRadius || 10.0,
        textFont: textFont,
        textColor: textColor,
        textScale: textScale,
        messages: messages
    };
    
    fetch('https://' + GetParentResourceName() + '/saveNPC', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            index: isEditMode ? selectedNPCIndex : null,
            npc: npcData
        })
    });
}

// ===== DELETE NPC =====
function deleteNPC() {
    if (selectedNPCIndex === null) return;
    
    if (confirm('NPC #' + (selectedNPCIndex + 1) + ' wirklich löschen?')) {
        fetch('https://' + GetParentResourceName() + '/deleteNPC', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ index: selectedNPCIndex })
        });
        showWelcome();
    }
}

function cancelEdit() {
    showWelcome();
}

function showWelcome() {
    selectedNPCIndex = null;
    document.getElementById('editorSection').style.display = 'none';
    document.getElementById('welcomeSection').style.display = 'block';
    renderNPCList();
}

// ===== LIVE PREVIEW =====
function updatePreview() {
    var font = document.getElementById('textFont').value || 'pricedown';
    var color = document.getElementById('textColor').value || 'gold';
    var scale = parseFloat(document.getElementById('textScale').value) || 0.968;
    
    var previewEl = document.getElementById('previewText');
    var scaleEl = document.getElementById('scaleValue');
    
    // Get first message line for preview text
    var msgs = document.getElementById('messages').value;
    var firstLine = 'Willkommen, Bürger...';
    if (msgs && msgs.trim()) {
        var lines = msgs.split('\n').filter(function(l) { return l.trim(); });
        if (lines.length > 0) firstLine = lines[0];
    }
    
    // Apply CSS classes for font + color
    previewEl.className = 'preview-text font-' + font + ' color-' + color;
    previewEl.style.fontSize = Math.round(scale * 22) + 'px';
    previewEl.textContent = firstLine;
    
    if (scaleEl) scaleEl.textContent = scale.toFixed(2);
}

// ===== POSITION/HEADING HELPERS =====
function getCurrentPosition() {
    fetch('https://' + GetParentResourceName() + '/getCurrentPosition', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

function getCurrentHeading() {
    fetch('https://' + GetParentResourceName() + '/getCurrentHeading', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

function GetParentResourceName() {
    if (window.location.href.indexOf('nui://') !== -1) {
        var matches = window.location.href.match(/nui:\/\/([^\/]+)\//);
        return matches ? matches[1] : 'INFONPC';
    }
    return 'INFONPC';
}
