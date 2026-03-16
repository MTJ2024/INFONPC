let currentNPCs = [];
let selectedNPCIndex = null;
let isEditMode = false;
let toastTimer = null;
let confirmCallback = null;
let infoPanelOpen = false;
let tickerTimer = null;

// Color map for preview and list dots
const COLOR_MAP = {
    gold:  '#ffdf00',
    weiss: '#ffffff',
    rot:   '#ff3232',
    gruen: '#32ff32',
    blau:  '#6496ff'
};

// ===== TOAST (ersetzt alert() — kein FiveM-Crash) =====
function showToast(message, type) {
    type = type || 'error';
    var toast = document.getElementById('toast');
    toast.textContent = message;
    toast.className = 'toast toast-' + type;
    if (toastTimer) clearTimeout(toastTimer);
    toastTimer = setTimeout(function() {
        toast.style.animation = 'toastOut 0.3s ease forwards';
        setTimeout(function() {
            toast.className = 'toast hidden';
            toast.style.animation = '';
        }, 300);
    }, 3000);
}

// ===== CONFIRM MODAL (ersetzt confirm() — kein FiveM-Crash) =====
function showConfirm(message, onYes) {
    var modal = document.getElementById('confirmModal');
    var text = document.getElementById('confirmText');
    text.textContent = message;
    confirmCallback = onYes;
    modal.classList.remove('hidden');
}

function onConfirmYes() {
    document.getElementById('confirmModal').classList.add('hidden');
    if (confirmCallback) confirmCallback();
    confirmCallback = null;
}

function onConfirmNo() {
    document.getElementById('confirmModal').classList.add('hidden');
    confirmCallback = null;
}

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
    } else if (data.action === 'hideForPlacement') {
        document.getElementById('npc-manager').classList.add('hidden');
    } else if (data.action === 'showAfterPlacement') {
        document.getElementById('npc-manager').classList.remove('hidden');
    } else if (data.action === 'showInfoPanel') {
        showInfoPanel(data.npcData);
    } else if (data.action === 'hideInfoPanel') {
        hideInfoPanel();
    } else if (data.action === 'showTicker') {
        showTicker(data.npcData);
    } else if (data.action === 'hideTicker') {
        hideTicker();
    }
});

// ESC to close
document.addEventListener('keyup', function(event) {
    if (event.key === 'Escape') {
        if (infoPanelOpen) {
            hideInfoPanel();
            fetch('https://' + GetParentResourceName() + '/closeInfoPanel', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });
        } else {
            closeUI();
        }
    }
});

// ===== NPC INFO PANEL (Professioneller Dialog) =====
function showInfoPanel(npcData) {
    if (!npcData) return;
    infoPanelOpen = true;
    
    var panel = document.getElementById('npcInfoPanel');
    var headerEl = document.getElementById('infoPanelHeader');
    var subEl = document.getElementById('infoPanelSubheader');
    var bodyEl = document.getElementById('infoPanelBody');
    var iconEl = document.getElementById('infoPanelIcon');
    
    // Header
    var header = npcData.header || 'Information';
    headerEl.textContent = header;
    
    // Icon aus dem Header extrahieren (erstes Emoji) oder Standard
    var emojiMatch = header.match(/^(\p{Emoji_Presentation}|\p{Emoji}\uFE0F)/u);
    if (emojiMatch) {
        iconEl.textContent = emojiMatch[0];
        headerEl.textContent = header.replace(emojiMatch[0], '').trim();
    } else {
        iconEl.textContent = 'ℹ️';
    }
    
    // Subheader
    if (npcData.subheader) {
        subEl.textContent = npcData.subheader;
        subEl.style.display = 'block';
    } else {
        subEl.style.display = 'none';
    }
    
    // Accent color based on textColor
    var accentColor = '#f59e0b';
    var colorMap = {
        gold: '#f59e0b', weiss: '#e2e8f0', rot: '#ef4444',
        gruen: '#22c55e', blau: '#3b82f6'
    };
    if (npcData.textColor && colorMap[npcData.textColor]) {
        accentColor = colorMap[npcData.textColor];
    }
    
    var accentEl = panel.querySelector('.npc-info-accent');
    accentEl.style.background = 'linear-gradient(90deg, ' + accentColor + ', ' + accentColor + 'cc, ' + accentColor + ')';
    
    iconEl.style.background = 'rgba(' + hexToRgb(accentColor) + ', 0.1)';
    iconEl.style.borderColor = 'rgba(' + hexToRgb(accentColor) + ', 0.2)';
    
    // Messages
    bodyEl.innerHTML = '';
    var messages = npcData.messages || [];
    messages.forEach(function(msg, i) {
        var row = document.createElement('div');
        row.className = 'npc-info-message';
        row.style.animationDelay = (i * 0.08) + 's';
        
        // ## Prefix = Größere Überschrift
        var isHeading = msg.startsWith('##');
        var displayMsg = isHeading ? msg.substring(2).trim() : msg;
        
        var bullet = document.createElement('div');
        bullet.className = 'npc-info-bullet';
        bullet.style.background = accentColor;
        bullet.style.boxShadow = '0 0 8px ' + accentColor + '4d';
        
        var text = document.createElement('div');
        text.className = isHeading ? 'npc-info-msg-text npc-info-msg-large' : 'npc-info-msg-text';
        text.textContent = displayMsg;
        
        if (isHeading) {
            bullet.style.width = '8px';
            bullet.style.height = '8px';
            bullet.style.minWidth = '8px';
            bullet.style.marginTop = '8px';
        }
        
        row.appendChild(bullet);
        row.appendChild(text);
        bodyEl.appendChild(row);
    });
    
    panel.classList.remove('hidden');
}

function hideInfoPanel() {
    infoPanelOpen = false;
    document.getElementById('npcInfoPanel').classList.add('hidden');
}

// ===== NPC TICKER / LAUFSCHRIFT =====
function showTicker(npcData) {
    if (!npcData || !npcData.messages) return;
    
    var ticker = document.getElementById('npcTicker');
    var content = document.getElementById('tickerContent');
    var accent = ticker.querySelector('.npc-ticker-accent');
    
    // Accent color
    var accentColor = '#f59e0b';
    var colorMap = {
        gold: '#f59e0b', weiss: '#e2e8f0', rot: '#ef4444',
        gruen: '#22c55e', blau: '#3b82f6'
    };
    if (npcData.textColor && colorMap[npcData.textColor]) {
        accentColor = colorMap[npcData.textColor];
    }
    accent.style.background = 'linear-gradient(90deg, ' + accentColor + ', ' + accentColor + 'cc, ' + accentColor + ')';
    
    // Build ticker content with ## support
    content.innerHTML = '';
    var messages = npcData.messages || [];
    
    // Header wenn vorhanden
    if (npcData.header) {
        var headerSpan = document.createElement('span');
        headerSpan.className = 'ticker-item ticker-header';
        headerSpan.textContent = npcData.header;
        headerSpan.style.color = accentColor;
        content.appendChild(headerSpan);
        
        var sep = document.createElement('span');
        sep.className = 'ticker-separator';
        sep.textContent = '◆';
        sep.style.color = accentColor;
        content.appendChild(sep);
    }
    
    messages.forEach(function(msg, i) {
        var isHeading = msg.startsWith('##');
        var displayMsg = isHeading ? msg.substring(2).trim() : msg;
        
        var span = document.createElement('span');
        span.className = isHeading ? 'ticker-item ticker-large' : 'ticker-item';
        span.textContent = displayMsg;
        content.appendChild(span);
        
        // Trenner zwischen Nachrichten
        if (i < messages.length - 1) {
            var sep = document.createElement('span');
            sep.className = 'ticker-separator';
            sep.textContent = '•';
            sep.style.color = accentColor;
            content.appendChild(sep);
        }
    });
    
    // Animation berechnen: Breite des Contents bestimmt Dauer
    ticker.classList.remove('hidden');
    content.style.animation = 'none';
    
    // Force reflow, dann Animation starten
    void content.offsetWidth;
    
    var contentWidth = content.scrollWidth;
    var viewportWidth = window.innerWidth;
    var totalDistance = contentWidth + viewportWidth;
    // Scrollgeschwindigkeit: ~80 Pixel pro Sekunde
    var duration = Math.max(8, totalDistance / 80);
    
    content.style.animation = 'tickerScroll ' + duration + 's linear forwards';
    
    // Nach Animation: Ticker ausblenden und Client benachrichtigen
    if (tickerTimer) clearTimeout(tickerTimer);
    tickerTimer = setTimeout(function() {
        hideTicker();
        fetch('https://' + GetParentResourceName() + '/tickerDone', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }, duration * 1000 + 500);
}

function hideTicker() {
    if (tickerTimer) {
        clearTimeout(tickerTimer);
        tickerTimer = null;
    }
    var ticker = document.getElementById('npcTicker');
    ticker.classList.add('hidden');
    var content = document.getElementById('tickerContent');
    content.style.animation = 'none';
}

function hexToRgb(hex) {
    hex = hex.replace('#', '');
    var r = parseInt(hex.substring(0, 2), 16);
    var g = parseInt(hex.substring(2, 4), 16);
    var b = parseInt(hex.substring(4, 6), 16);
    return r + ', ' + g + ', ' + b;
}

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
        
        // Style badge
        var styleBadge = document.createElement('span');
        styleBadge.className = 'style-badge';
        var styleIcons = { panel: '🪟', ticker: '📰', classic: '📝' };
        styleBadge.textContent = styleIcons[npc.dialogStyle] || '📝';
        header.appendChild(styleBadge);
        
        var title = document.createElement('span');
        var maxListLen = 20;
        title.textContent = npc.header ? npc.header.substring(0, maxListLen) : ('NPC #' + (index + 1));
        header.appendChild(title);
        
        var info = document.createElement('div');
        info.className = 'npc-item-info';
        var msgCount = (npc.messages && npc.messages.length) || 0;
        var styleNames = { panel: 'Panel', ticker: 'Ticker', classic: 'Klassisch' };
        var style = styleNames[npc.dialogStyle] || 'Klassisch';
        info.textContent = (npc.pedModel || '?') + ' | ' + msgCount + ' Nachr. | ' + style;
        
        item.appendChild(header);
        item.appendChild(info);
        listContainer.appendChild(item);
    });
}

// ===== DIALOG STYLE TOGGLE =====
function onDialogStyleChange() {
    var style = document.getElementById('dialogStyle').value;
    var panelFields = document.getElementById('panelFields');
    panelFields.style.display = (style === 'panel' || style === 'ticker') ? 'block' : 'none';
    updatePreview();
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
    
    document.getElementById('dialogStyle').value = 'panel';
    document.getElementById('npcHeader').value = '';
    document.getElementById('npcSubheader').value = '';
    onDialogStyleChange();
    
    setPedModel('a_f_y_business_01');
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
    
    document.getElementById('editorTitle').textContent = npc.header ? npc.header.substring(0, 30) + (npc.header.length > 30 ? '…' : '') : ('NPC #' + (index + 1) + ' bearbeiten');
    document.getElementById('deleteBtn').style.display = 'inline-block';
    document.getElementById('editorSection').style.display = 'block';
    document.getElementById('welcomeSection').style.display = 'none';
    
    document.getElementById('dialogStyle').value = npc.dialogStyle || 'classic';
    document.getElementById('npcHeader').value = npc.header || '';
    document.getElementById('npcSubheader').value = npc.subheader || '';
    onDialogStyleChange();
    
    setPedModel(npc.pedModel || 'a_f_y_business_01');
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
    var dialogStyle = document.getElementById('dialogStyle').value || 'classic';
    var npcHeader = document.getElementById('npcHeader').value.trim();
    var npcSubheader = document.getElementById('npcSubheader').value.trim();
    
    if (!pedModel) {
        showToast('⚠️ Bitte wähle ein Ped Model!', 'error');
        return;
    }
    if (isNaN(posX) || isNaN(posY) || isNaN(posZ)) {
        showToast('⚠️ Bitte gib gültige Koordinaten ein!\nNutze den Button "Aktuelle Position".', 'error');
        return;
    }
    
    var messages = messagesText.split('\n').filter(function(m) { return m.trim() !== ''; });
    if (messages.length === 0) {
        showToast('⚠️ Bitte gib mindestens eine Nachricht ein!', 'error');
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
        dialogStyle: dialogStyle,
        header: npcHeader,
        subheader: npcSubheader,
        messages: messages
    };
    
    fetch('https://' + GetParentResourceName() + '/saveNPC', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            index: isEditMode ? selectedNPCIndex : null,
            npc: npcData
        })
    }).then(function() {
        showToast('✅ NPC gespeichert!', 'success');
    });
}

// ===== DELETE NPC =====
function deleteNPC() {
    if (selectedNPCIndex === null) return;
    
    var label = currentNPCs[selectedNPCIndex].header || ('NPC #' + (selectedNPCIndex + 1));
    showConfirm(label + ' wirklich löschen?', function() {
        fetch('https://' + GetParentResourceName() + '/deleteNPC', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ index: selectedNPCIndex })
        }).then(function() {
            showToast('✅ NPC gelöscht!', 'success');
        });
        showWelcome();
    });
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
    var dialogStyle = document.getElementById('dialogStyle').value || 'classic';
    
    var previewClassic = document.getElementById('previewClassic');
    var previewPanel = document.getElementById('previewPanel');
    var previewEl = document.getElementById('previewText');
    var scaleEl = document.getElementById('scaleValue');
    
    // Get first message line for preview text
    var msgs = document.getElementById('messages').value;
    var firstLine = 'Willkommen, Bürger...';
    if (msgs && msgs.trim()) {
        var lines = msgs.split('\n').filter(function(l) { return l.trim(); });
        if (lines.length > 0) {
            firstLine = lines[0];
            // Strip ## prefix for preview display
            if (firstLine.startsWith('##')) firstLine = firstLine.substring(2).trim();
        }
    }
    
    // Accent color mapping for panel/ticker preview
    var accentHex = COLOR_MAP[color] || '#ffdf00';
    
    if (dialogStyle === 'panel') {
        previewClassic.style.display = 'none';
        previewPanel.style.display = 'block';
        var headerEl = document.getElementById('previewPanelHeader');
        headerEl.textContent = document.getElementById('npcHeader').value || 'Header...';
        headerEl.style.color = accentHex;
        document.getElementById('previewPanelSub').textContent = document.getElementById('npcSubheader').value || 'Untertitel...';
        document.getElementById('previewPanelMsg').textContent = firstLine;
    } else if (dialogStyle === 'ticker') {
        previewClassic.style.display = 'none';
        previewPanel.style.display = 'block';
        var hdr = document.getElementById('npcHeader').value || '';
        var tickerHeaderEl = document.getElementById('previewPanelHeader');
        tickerHeaderEl.textContent = '📰 ' + (hdr || 'Laufschrift');
        tickerHeaderEl.style.color = accentHex;
        document.getElementById('previewPanelSub').textContent = '◀ scrollt über den Bildschirm ▶';
        document.getElementById('previewPanelMsg').textContent = firstLine;
    } else {
        previewClassic.style.display = 'block';
        previewPanel.style.display = 'none';
        previewEl.className = 'preview-text font-' + font + ' color-' + color;
        previewEl.style.fontSize = Math.round(scale * 22) + 'px';
        previewEl.textContent = firstLine;
    }
    
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
    fetch('https://' + GetParentResourceName() + '/startHeadingPlacement', {
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
